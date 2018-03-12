//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

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
    @IBOutlet private weak var openSlidesButton: UIButton!

    var courseItem: CourseItem!
    var video: Video?
    var videoPlayerConfigured = false
    private var sentFirstAutoPlayEvent = false

    var player: CustomBMPlayer?
    let playerControlView = VideoPlayerControlView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionView.textContainerInset = UIEdgeInsets.zero
        self.descriptionView.textContainer.lineFragmentPadding = 0

        self.layoutPlayer()

        self.errorView.isHidden = true
        self.openSlidesButton.isHidden = true
        self.openSlidesButton.isEnabled = ReachabilityHelper.connection != .none

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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)

        CrashlyticsHelper.shared.setObjectValue("item_id", forKey: self.courseItem.id)
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
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoContainer.snp.top)
            make.bottom.equalTo(self.videoContainer.snp.bottom)
            make.centerX.equalTo(self.videoContainer.snp.centerX)
            make.width.equalTo(self.videoContainer.snp.height).multipliedBy(16.0 / 9.0)
        }

        self.player = player
        self.videoContainer.layoutIfNeeded()
    }

    @objc func reachabilityChanged() {
        self.openSlidesButton.isEnabled = ReachabilityHelper.connection != .none
        self.updatePreferredVideoBitrate()
    }

    private func updateView(for courseItem: CourseItem) {
        self.titleView.text = courseItem.title

        guard let video = courseItem.content as? Video else { return }

        self.show(video: video)
    }

    private func show(video: Video) {
        self.video = video

        // show slides button
        self.openSlidesButton.isHidden = (video.slidesURL == nil)

        // show description
        if let summary = video.summary {
            let markDown = try? MarkdownHelper.parse(summary)
            self.descriptionView.attributedText = markDown
            self.descriptionView.isHidden = markDown?.string.isEmpty ?? true
        } else {
            self.descriptionView.isHidden = true
        }

        // configure video player
        if self.videoPlayerConfigured { return }

        // pull latest change for video content item
        video.managedObjectContext?.refresh(video, mergeChanges: true)

        // determine video url (local file, currently downloading or remote)
        var videoURL: URL
        if let localAsset = VideoPersistenceManager.shared.localAsset(for: video) {
            videoURL = localAsset.url
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

    @IBAction func openSlides(_ sender: UIButton) {
        if ReachabilityHelper.connection != .none {
            performSegue(withIdentifier: "ShowSlides", sender: self.video)
        } else {
            log.info("Tapped open slides button without internet, which shouldn't be possible")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowSlides"?:
            if let vc = segue.destination as? WebViewController {
                vc.url = self.video?.slidesURL?.absoluteString
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
        if let video = self.video, VideoPersistenceManager.shared.localAsset(for: video) == nil {
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

    func trackVideoSeek(from: TimeInterval?, to: TimeInterval) {
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
            player.avPlayer?.rate = self.playerControlView.playRate  // has to be set after playback started

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
