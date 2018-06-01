//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length type_body_length

import AVFoundation
import AVKit
import BMPlayer
import NVActivityIndicatorView
import UIKit

class VideoViewController: UIViewController {

    @IBOutlet private weak var videoContainer: UIView!
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!

    @IBOutlet private weak var videoActionsButton: UIButton!
    @IBOutlet private weak var videoProgressView: CircularProgressView!
    @IBOutlet private weak var videoDownloadedIcon: UIImageView!

    @IBOutlet private weak var slidesView: UIView!
    @IBOutlet private weak var slidesButton: UIButton!
    @IBOutlet private weak var slidesActionsButton: UIButton!
    @IBOutlet private weak var slidesProgressView: CircularProgressView!
    @IBOutlet private weak var slidesDownloadedIcon: UIImageView!

    @IBOutlet private var iPadFullScreenContraints: [NSLayoutConstraint]!

    var courseItem: CourseItem!
    var video: Video?
    var videoPlayerConfigured = false
    private var sentFirstAutoPlayEvent = false

    var player: CustomBMPlayer?
    let playerControlView = VideoPlayerControlView()

    override func viewDidLoad() { // swiftlint:disable:this function_body_length
        super.viewDidLoad()
        self.descriptionView.textContainerInset = UIEdgeInsets.zero
        self.descriptionView.textContainer.lineFragmentPadding = 0

        self.layoutPlayer()

        self.errorView.isHidden = true

        self.navigationItem.rightBarButtonItem?.isEnabled = ReachabilityHelper.connection != .none
        self.navigationItem.rightBarButtonItem?.tintColor = ReachabilityHelper.connection != .none ? Brand.Color.primary : .lightGray

        self.videoActionsButton.isEnabled = ReachabilityHelper.connection != .none
        self.videoActionsButton.tintColor = ReachabilityHelper.connection != .none ? Brand.Color.primary : .lightGray
        self.videoProgressView.isHidden = true
        self.videoDownloadedIcon.tintColor = UIColor.darkText.withAlphaComponent(0.7)
        self.videoDownloadedIcon.isHidden = true

        self.slidesView.isHidden = true
        self.slidesButton.isEnabled = ReachabilityHelper.connection != .none
        self.slidesActionsButton.isEnabled = ReachabilityHelper.connection != .none
        self.slidesActionsButton.tintColor = ReachabilityHelper.connection != .none ? Brand.Color.primary : .lightGray
        self.slidesProgressView.isHidden = true
        self.slidesDownloadedIcon.tintColor = UIColor.darkText.withAlphaComponent(0.7)
        self.slidesDownloadedIcon.isHidden = true

        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { syncResult in
            CoreDataHelper.viewContext.perform {
                guard let courseItem = CoreDataHelper.viewContext.existingTypedObject(with: syncResult.objectId) as? CourseItem else {
                    log.warning("Failed to retrieve course item to display")
                    return
                }

                self.courseItem = courseItem
                DispatchQueue.main.async {
                    self.updateView(for: self.courseItem)
                }
            }
        }

        // register notification observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                       name: NotificationKeys.DownloadStateDidChange,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadProgressNotification(_:)),
                                       name: NotificationKeys.DownloadProgressDidChange,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(reachabilityChanged),
                                       name: Notification.Name.reachabilityChanged,
                                       object: nil)

        CrashlyticsHelper.shared.setObjectValue(self.courseItem.id, forKey: "item_id")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toggleControlBars(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !(self.navigationController?.viewControllers.contains(self) ?? false) {
            self.player?.pause()
        }

        if !(self.navigationController?.viewControllers.contains(self) ?? true) {
            self.trackVideoClose()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let courseNavigationController = self.navigationController as? CourseNavigationController,
            let courseTransitioningDelegate = courseNavigationController.transitioningDelegate as? CourseTransitioningDelegate,
            courseTransitioningDelegate.interactionController.shouldFinish {
            self.player?.pause()
            self.trackVideoClose()
        }
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        let orientation = UIDevice.current.orientation
        let isInLandscapeOrientation = orientation == .landscapeRight || orientation == .landscapeLeft
        return UIDevice.current.userInterfaceIdiom == .phone && isInLandscapeOrientation
    }

    func layoutPlayer() {
        self.playerControlView.videoController = self

        BMPlayerConf.topBarShowInCase = .always
        BMPlayerConf.loaderType = NVActivityIndicatorType.ballScale
        BMPlayerConf.enableVolumeGestures = false
        BMPlayerConf.enableBrightnessGestures = false
        BMPlayerConf.enablePlaytimeGestures = true

        self.playerControlView.changeOrientation(to: UIDevice.current.orientation)
        let player = CustomBMPlayer(customControlView: self.playerControlView)
        player.delegate = self
        player.videoController = self
        self.videoContainer.addSubview(player)
        player.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        self.player = player
        self.videoContainer.layoutIfNeeded()
    }

    func activateiPadFullScreenMode(_ isFullScreen: Bool) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            if isFullScreen {
                NSLayoutConstraint.activate(self.iPadFullScreenContraints)
            } else {
                NSLayoutConstraint.deactivate(self.iPadFullScreenContraints)
            }

            self.view.layoutIfNeeded()
        }
    }

    private func updateView(for courseItem: CourseItem) {
        self.titleView.text = courseItem.title

        guard let video = courseItem.content as? Video else { return }

        self.show(video: video)
    }

    private func show(video: Video) { // swiftlint:disable:this function_body_length
        self.video = video

        let videoDownloadState = StreamPersistenceManager.shared.downloadState(for: video)
        let progress = StreamPersistenceManager.shared.downloadProgress(for: video)
        self.videoProgressView.isHidden = videoDownloadState == .notDownloaded || videoDownloadState == .downloaded
        self.videoProgressView.updateProgress(progress, animated: false)
        self.videoDownloadedIcon.isHidden = !(videoDownloadState == .downloaded)

        self.navigationItem.rightBarButtonItem?.isEnabled = !video.userActions.isEmpty
        self.navigationItem.rightBarButtonItem?.tintColor = !video.userActions.isEmpty ? Brand.Color.primary : .lightGray

        self.videoActionsButton.isEnabled = !video.userActions.isEmpty
        self.videoActionsButton.tintColor = !video.userActions.isEmpty ? Brand.Color.primary : .lightGray

        // show slides button
        self.slidesView.isHidden = (video.slidesURL == nil)

        // show description
        if let summary = video.summary {
            MarkdownHelper.attributedString(for: summary).onSuccess(DispatchQueue.main.context) { attributedString in
                self.descriptionView.attributedText = attributedString
                self.descriptionView.isHidden = attributedString.string.isEmpty
            }
        } else {
            self.descriptionView.isHidden = true
        }

        // configure video player
        if self.videoPlayerConfigured { return }

        // pull latest change for video content item
        video.managedObjectContext?.refresh(video, mergeChanges: true)

        // determine video url (local file, currently downloading or remote)
        var videoURL: URL
        if let localFileLocation = StreamPersistenceManager.shared.localFileLocation(for: video) {
            videoURL = localFileLocation
            self.playerControlView.setOffline(true)
        } else if let hlsURL = video.singleStream?.hlsURL {
            videoURL = hlsURL
            self.playerControlView.setOffline(false)
        } else if let hdURL = video.singleStream?.hdURL, ReachabilityHelper.connection == .wifi {
            videoURL = hdURL
            self.playerControlView.setOffline(false)
        } else if let sdURL = video.singleStream?.sdURL {
            videoURL = sdURL
            self.playerControlView.setOffline(false)
        } else {
            self.errorView.isHidden = false
            self.playerControlView.setOffline(false)
            return
        }

        self.videoPlayerConfigured = true
        self.errorView.isHidden = true

        let asset = BMPlayerResource(url: videoURL, name: self.courseItem?.title ?? "")
        self.player?.setVideo(resource: asset)
        self.updatePreferredVideoBitrate()
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }

    @IBAction func openSlides() {
        if ReachabilityHelper.connection != .none {
            self.performSegue(withIdentifier: R.segue.videoViewController.showSlides, sender: self.video)
        } else {
            log.info("Tapped open slides button without internet, which shouldn't be possible")
        }
    }

    @IBAction func showActionMenu(_ sender: UIBarButtonItem) {
        guard let actions = self.video?.userActions else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender

        for action in actions {
            alert.addAction(action)
        }

        alert.addCancelAction()

        self.present(alert, animated: true)
    }

    @IBAction func showVideoActionMenu(_ sender: UIButton) {
        guard let streamUserAction = self.video?.streamUserAction else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds.insetBy(dx: -4, dy: -4)

        alert.addAction(streamUserAction)
        alert.addCancelAction()

        self.present(alert, animated: true)
    }

    @IBAction func showSlidesActionMenu(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds.insetBy(dx: -4, dy: -4)

        let openSlidesActionTitle = NSLocalizedString("course-item.slides-alert.open-action.title", comment: "title to cancel alert")
        let openSlides = UIAlertAction(title: openSlidesActionTitle, style: .default) { _ in
            self.openSlides()
        }

        alert.addAction(openSlides)

        if let slidesUserAction = self.video?.slidesUserAction {
            alert.addAction(slidesUserAction)
        }

        alert.addCancelAction()

        self.present(alert, animated: true)
    }

    @objc func handleAssetDownloadStateChangedNotification(_ noticaition: Notification) {
        guard let resourceType = noticaition.userInfo?[DownloadNotificationKey.type] as? String,
            let videoId = noticaition.userInfo?[DownloadNotificationKey.id] as? String,
            let downloadStateRawValue = noticaition.userInfo?[DownloadNotificationKey.downloadState] as? String,
            let downloadState = DownloadState(rawValue: downloadStateRawValue),
            let video = self.video,
            resourceType == Video.type,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.videoProgressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
            self.videoProgressView.updateProgress(StreamPersistenceManager.shared.downloadProgress(for: video))
            self.videoDownloadedIcon.isHidden = !(downloadState == .downloaded)
        }
    }

    @objc func handleAssetDownloadProgressNotification(_ noticaition: Notification) {
        guard let resourceType = noticaition.userInfo?[DownloadNotificationKey.type] as? String,
            let videoId = noticaition.userInfo?[DownloadNotificationKey.id] as? String,
            let progress = noticaition.userInfo?[DownloadNotificationKey.downloadProgress] as? Double,
            let video = self.video,
            resourceType == Video.type,
            video.id == videoId else { return }

        DispatchQueue.main.async {
            self.videoProgressView.isHidden = false
            self.videoProgressView.updateProgress(progress)
        }
    }

    @objc func reachabilityChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = ReachabilityHelper.connection != .none
        self.navigationItem.rightBarButtonItem?.tintColor = ReachabilityHelper.connection != .none ? Brand.Color.primary : .lightGray

        self.videoActionsButton.isEnabled = self.video?.streamUserAction != nil
        self.videoActionsButton.tintColor = self.video?.streamUserAction != nil ? Brand.Color.primary : .lightGray

        self.slidesActionsButton.isEnabled = ReachabilityHelper.connection != .none
        self.slidesActionsButton.tintColor = ReachabilityHelper.connection != .none ? Brand.Color.primary : .lightGray
        self.slidesButton.isEnabled = ReachabilityHelper.connection != .none

        self.updatePreferredVideoBitrate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.videoViewController.showSlides(segue: segue) {
            typedInfo.destination.url = self.video?.slidesURL
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.toggleControlBars(true)
        self.playerControlView.changeOrientation(to: UIDevice.current.orientation)

        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }

    @discardableResult private func toggleControlBars(_ animated: Bool) -> Bool {
        let hiddenBars = UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone
        self.navigationController?.setNavigationBarHidden(hiddenBars, animated: animated)
        self.tabBarController?.tabBar.isHidden = hiddenBars
        return hiddenBars
    }

    private func updatePreferredVideoBitrate() {
        if let video = self.video, StreamPersistenceManager.shared.localFileLocation(for: video) == nil {
            let videoQuaility: VideoQuality
            if ReachabilityHelper.connection == .wifi {
                videoQuaility = UserDefaults.standard.videoQualityOnWifi
            } else {
                videoQuaility = UserDefaults.standard.videoQualityOnCellular
            }

            self.player?.avPlayer?.currentItem?.preferredPeakBitRate = Double(videoQuaility.rawValue)
        }
    }

}

extension VideoViewController { // Video tracking

    private var newTrackingContext: [String: String?] {
        var context = [
            "section_id": self.video?.item?.section?.id,
            "course_id": self.video?.item?.section?.course?.id,
            "current_speed": String(self.playerControlView.playRate),
            "current_orientation": UIDevice.current.orientation.isLandscape ? "landscape" : "portrait",
            "current_quality": "hls",
            "current_source": self.playerControlView.offlineLabel.isHidden ? "online" : "offline",
        ]

        if let currentTime = self.player?.avPlayer?.currentTime().seconds {
            context["currentTime"] = String(describing: currentTime)
        }

        return context
    }

    func trackVideoPlay() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackPlay, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoPause() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackPause, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoPlayRateChange(oldPlayRate: Float, newPlayRate: Float) {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_speed"] = nil
        context["old_speed"] = String(oldPlayRate)
        context["new_speed"] = String(newPlayRate)
        TrackingHelper.createEvent(.videoPlaybackChangeSpeed, resourceType: .video, resourceId: video.id, context: context)
    }

    func trackVideoSeek(from: TimeInterval?, to: TimeInterval) { // swiftlint:disable:this identifier_name
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_time"] = nil
        context["new_current_time"] = String(to)

        if let from = from {
            context["old_current_time"] = String(from)
        }

        TrackingHelper.createEvent(.videoPlaybackSeek, resourceType: .video, resourceId: video.id, context: context)
    }

    func trackVideoEnd() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackEnd, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoClose() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackClose, resourceType: .video, resourceId: video.id, context: self.newTrackingContext)
    }

    func trackVideoOrientationChangePortrait() {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_orientation"] = nil
        TrackingHelper.createEvent(.videoPlaybackDeviceOrientationPortrait, resourceType: .video, resourceId: video.id, context: context)
    }

    func trackVideoOrientationChangeLandscape() {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_orientation"] = nil
        TrackingHelper.createEvent(.videoPlaybackDeviceOrientationLandscape, resourceType: .video, resourceId: video.id, context: context)
    }

}

extension VideoViewController: BMPlayerDelegate {

    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        if state == .bufferFinished {
            if player.isPlaying {
                player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started
            }

            if !self.sentFirstAutoPlayEvent {  // only once
                self.trackVideoPlay()
                self.sentFirstAutoPlayEvent = true
            }

        } else if state == .playedToTheEnd {
            self.trackVideoEnd()
        }
    }

    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
    }

    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
    }

    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        if playing {
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started
        }
    }

    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        if UIDevice.current.orientation.isLandscape {
            self.trackVideoOrientationChangeLandscape()
        } else {
            self.trackVideoOrientationChangePortrait()
        }
    }

}
