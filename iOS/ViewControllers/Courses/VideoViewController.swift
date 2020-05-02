//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length type_body_length

import AVFoundation
import AVKit
import Binge
import Common
import UIKit

class VideoViewController: UIViewController {

    @IBOutlet private weak var videoContainer: UIView!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet weak var learningMaterialsView: UIStackView!

    @IBOutlet private weak var videoActionsButton: UIButton!
    @IBOutlet private weak var videoProgressView: CircularProgressView!
    @IBOutlet private weak var videoDownloadedIcon: UIImageView!

    @IBOutlet private weak var slidesView: UIView!
    @IBOutlet private weak var slidesButton: UIButton!
    @IBOutlet private weak var slidesActionsButton: UIButton!
    @IBOutlet private weak var slidesProgressView: CircularProgressView!
    @IBOutlet private weak var slidesDownloadedIcon: UIImageView!

    @IBOutlet private var fullScreenContraints: [NSLayoutConstraint]!

    private var adjustedVideoContainerRatioConstraint: NSLayoutConstraint? {
        didSet {
            if let oldConstraint = oldValue {
                self.videoContainer.removeConstraint(oldConstraint)
            }

            if let newConstraint = self.adjustedVideoContainerRatioConstraint {
                self.videoContainer.addConstraint(newConstraint)
            }

            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private var courseItemObserver: ManagedObjectObserver?

    var courseItem: CourseItem! {
        didSet {
            self.courseItemObserver = ManagedObjectObserver(object: self.courseItem) { [weak self] type in
                guard type == .update else { return }
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.updateView(for: strongSelf.courseItem)
                }
            }
        }
    }

    private var videoIsShownInFullScreen = false {
        didSet {
            guard self.videoIsShownInFullScreen != oldValue else { return }
            self.updateUIForFullScreenMode(trueUnlessReduceMotionEnabled)
        }
    }

    private var video: Video?
    private var didViewAppear = false
    private var isFirstAppearance = true

    private var playerViewController: BingePlayerViewController? {
        didSet {
            self.playerViewController?.delegate = self
            self.playerViewController?.tintColor = Brand.default.colors.window
        }
    }

    private var isInForeground: Bool {
        if #available(iOS 13, *) {
            return [UIScene.ActivationState.foregroundActive, .foregroundInactive].contains(self.view.window?.windowScene?.activationState)
        } else {
            return [UIApplication.State.active, .inactive].contains(UIApplication.shared.applicationState)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionView.textContainerInset = UIEdgeInsets.zero
        self.descriptionView.textContainer.lineFragmentPadding = 0
        self.descriptionView.delegate = self

        self.titleView.text = self.courseItem.title
        self.descriptionView.isHidden = true
        self.learningMaterialsView.isHidden = true

        self.updateCornersOfVideoContainer(for: self.traitCollection)

        self.videoActionsButton.isEnabled = false
        self.videoActionsButton.tintColor = ColorCompatibility.disabled
        self.videoActionsButton.addDefaultPointerInteraction()
        self.videoProgressView.isHidden = true
        self.videoDownloadedIcon.tintColor = ColorCompatibility.disabled.withAlphaComponent(0.7)
        self.videoDownloadedIcon.isHidden = true

        self.slidesView.isHidden = true
        self.slidesDownloadedIcon.tintColor = ColorCompatibility.disabled.withAlphaComponent(0.7)
        self.slidesButton.addDefaultPointerInteraction()
        self.slidesActionsButton.addDefaultPointerInteraction()

        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem)

        // Add pan gesture recognizer to video container to prevent an accidental course item switch or course dismissal
        self.videoContainer.addGestureRecognizer(UIPanGestureRecognizer())

        // register notification observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadStateChangedNotification(_:)),
                                       name: DownloadState.didChangeNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadProgressNotification(_:)),
                                       name: DownloadProgress.didChangeNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(reachabilityChanged),
                                       name: Notification.Name.reachabilityChanged,
                                       object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toggleControlBars(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.didViewAppear = true

        // Autoplay logic
        if self.isFirstAppearance {
            self.playerViewController?.startPlayback()
        } else {
            self.playerViewController?.showControlsOverlay()
        }

        self.isFirstAppearance = false

        self.playerViewController?.automaticallyStopPicutureinPictureModeIfNecessary()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard let pageViewController = self.parent as? UIPageViewController else { return }
        let isNotPresentedInPageViewController = !(pageViewController.viewControllers?.contains(self) ?? false)
        let pageViewControllerDismissed = pageViewController.parent?.presentingViewController == nil
        guard isNotPresentedInPageViewController || pageViewControllerDismissed else { return }

        if isNotPresentedInPageViewController && !pageViewControllerDismissed {
            self.playerViewController?.pausePlayback()
        }

        if self.didViewAppear {
            self.playerViewController?.automaticallyStopPicutureinPictureModeIfNecessary(force: true)
            self.trackVideoClose()
        }

        self.didViewAppear = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.videoViewController.showSlides(segue: segue), let video = video {
            if let url = SlidesPersistenceManager.shared.localFileLocation(for: video) ?? video.slidesURL {
                typedInfo.destination.configure(for: url, filename: self.courseItem.title)
            }
        } else if let typedInfo = R.segue.videoViewController.embedPlayer(segue: segue) {
            self.playerViewController = typedInfo.destination
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.updateUIForFullScreenMode(false)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updateCornersOfVideoContainer(for: newCollection)
    }

    override var childForStatusBarStyle: UIViewController? {
        guard self.playerViewController?.layoutState == .fullScreen else { return nil }
        return self.playerViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        guard self.playerViewController?.layoutState == .fullScreen else { return nil }
        return self.playerViewController
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        guard self.playerViewController?.layoutState == .fullScreen else { return nil }
        return self.playerViewController
    }

    private func updateView(for courseItem: CourseItem) {
        guard let video = courseItem.content as? Video else { return }
        self.video = video

        self.descriptionView.isHidden = false 
        self.learningMaterialsView.isHidden = false

        self.show(video: video)
    }

    private func show(video: Video) {
        self.video = video

        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: video)
        let streamDownloadProgress = StreamPersistenceManager.shared.downloadProgress(for: video)
        self.videoProgressView.isHidden = streamDownloadState == .notDownloaded || streamDownloadState == .downloaded
        self.videoProgressView.updateProgress(streamDownloadProgress, animated: false)
        self.videoDownloadedIcon.isHidden = streamDownloadState != .downloaded

        let isVideoActionsButtonEnabled = ReachabilityHelper.hasConnection || video.streamAlertAction != nil
        self.videoActionsButton.isEnabled = isVideoActionsButtonEnabled
        self.videoActionsButton.tintColor = isVideoActionsButtonEnabled ? Brand.default.colors.primary : ColorCompatibility.disabled

        // show slides button
        self.slidesView.isHidden = (video.slidesURL == nil)
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: video)
        let slidesDownloadProgress = SlidesPersistenceManager.shared.downloadProgress(for: video)
        self.slidesProgressView.isHidden = slidesDownloadState == .notDownloaded || slidesDownloadState == .downloaded
        self.slidesProgressView.updateProgress(slidesDownloadProgress, animated: false)
        self.slidesDownloadedIcon.isHidden = !(slidesDownloadState == .downloaded)

        let isSlidesActionButtonEnabled = ReachabilityHelper.hasConnection || video.slidesAlertAction != nil
        self.slidesActionsButton.isEnabled = isSlidesActionButtonEnabled
        self.slidesActionsButton.tintColor = isSlidesActionButtonEnabled ? Brand.default.colors.primary : ColorCompatibility.disabled

        // show description
        self.descriptionView.setMarkdownWithImages(from: video.summary)

        // don't reconfigure video player
        guard self.playerViewController?.asset == nil else { return }

        // pull latest change for video content item
        video.managedObjectContext?.refresh(video, mergeChanges: true)

        self.playerViewController?.configure(for: video)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    }

    @IBAction private func openSlides() {
        self.performSegue(withIdentifier: R.segue.videoViewController.showSlides, sender: self.video)
        self.playerViewController?.automaticallyStartPicutureinPictureModeIfPossible()
    }

    @IBAction private func showVideoActionMenu(_ sender: UIButton) {
        guard let streamAlertAction = self.video?.streamAlertAction else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds.insetBy(dx: -4, dy: -4)
        alert.popoverPresentationController?.permittedArrowDirections = [.left, .right]

        alert.addAction(streamAlertAction)
        alert.addCancelAction()

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func showSlidesActionMenu(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds.insetBy(dx: -4, dy: -4)
        alert.popoverPresentationController?.permittedArrowDirections = [.left, .right]

        let openSlidesActionTitle = NSLocalizedString("course-item.slides-alert.open-action.title", comment: "title to cancel alert")
        let openSlides = UIAlertAction(title: openSlidesActionTitle, style: .default) { _ in
            self.openSlides()
        }

        alert.addAction(openSlides)

        if let slidesAlertAction = self.video?.slidesAlertAction {
            alert.addAction(slidesAlertAction)
        }

        alert.addCancelAction()

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func handleAssetDownloadStateChangedNotification(_ notification: Notification) {
        guard let downloadType = notification.userInfo?[DownloadNotificationKey.downloadType] as? String,
            let videoId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
            let downloadStateRawValue = notification.userInfo?[DownloadNotificationKey.downloadState] as? String,
            let downloadState = DownloadState(rawValue: downloadStateRawValue),
            let video = self.video,
            video.id == videoId else { return }

        if downloadType == StreamPersistenceManager.Configuration.downloadType {
            DispatchQueue.main.async {
                self.videoProgressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
                self.videoProgressView.updateProgress(StreamPersistenceManager.shared.downloadProgress(for: video))
                self.videoDownloadedIcon.isHidden = !(downloadState == .downloaded)
            }
        } else if downloadType == SlidesPersistenceManager.Configuration.downloadType {
            DispatchQueue.main.async {
                self.slidesProgressView.isHidden = downloadState == .notDownloaded || downloadState == .downloaded
                self.slidesProgressView.updateProgress(SlidesPersistenceManager.shared.downloadProgress(for: video))
                self.slidesDownloadedIcon.isHidden = !(downloadState == .downloaded)
                let actionButtonEnabled = ReachabilityHelper.hasConnection || self.video?.slidesAlertAction != nil
                self.slidesActionsButton.isEnabled = actionButtonEnabled
                self.slidesActionsButton.tintColor = actionButtonEnabled ? Brand.default.colors.primary : ColorCompatibility.systemGray4
            }
        }
    }

    @objc private func handleAssetDownloadProgressNotification(_ notification: Notification) {
        guard let downloadType = notification.userInfo?[DownloadNotificationKey.downloadType] as? String,
            let videoId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
            let progress = notification.userInfo?[DownloadNotificationKey.downloadProgress] as? Double,
            let video = self.video,
            video.id == videoId else { return }

        if downloadType == StreamPersistenceManager.Configuration.downloadType {
            DispatchQueue.main.async {
                self.videoProgressView.isHidden = false
                self.videoProgressView.updateProgress(progress)
            }
        } else if downloadType == SlidesPersistenceManager.Configuration.downloadType {
            DispatchQueue.main.async {
                self.slidesProgressView.isHidden = false
                self.slidesProgressView.updateProgress(progress)
            }
        }
    }

    @objc private func reachabilityChanged() {
        self.updateView(for: self.courseItem)
        self.playerViewController?.preferredPeakBitRate = self.video?.preferredPeakBitRate()
    }

    private func toggleControlBars(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(self.videoIsShownInFullScreen, animated: animated)
    }

    private func updateCornersOfVideoContainer(for traitCollection: UITraitCollection) {
        let shouldRoundCorners = traitCollection.horizontalSizeClass == .regular && !self.videoIsShownInFullScreen
        self.videoContainer.layer.cornerRadius = shouldRoundCorners ? 6 : 0
        self.videoContainer.layer.masksToBounds = shouldRoundCorners
    }

    private func updateUIForFullScreenMode(_ animated: Bool) {
        DispatchQueue.main.async {
            self.toggleControlBars(animated)

            if self.videoIsShownInFullScreen {
                NSLayoutConstraint.activate(self.fullScreenContraints)
            } else {
                NSLayoutConstraint.deactivate(self.fullScreenContraints)
            }

            let animationDuration = animated ? 0.25 : 0

            // swiftlint:disable:next trailing_closure
            UIView.animate(withDuration: animationDuration, delay: 0, options: .layoutSubviews, animations: {
                self.updateCornersOfVideoContainer(for: self.traitCollection)
                self.view.layoutIfNeeded()
            })
        }
    }

    private func adaptVideoContainerToVideoSize() {
        guard let videoSize = self.playerViewController?.videoSize else { return }

        let newRatio = videoSize.width / videoSize.height
        let oldRatio = self.adjustedVideoContainerRatioConstraint?.multiplier

        if newRatio.isNaN { return }
        if newRatio == oldRatio { return }

        let constraint = NSLayoutConstraint(item: self.videoContainer as Any,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: self.videoContainer,
                                            attribute: .height,
                                            multiplier: newRatio,
                                            constant: 0)
        constraint.priority = .required - 1
        self.adjustedVideoContainerRatioConstraint = constraint
    }

}

extension VideoViewController: BingePlayerDelegate { // Video tracking

    private var newTrackingContext: [String: String?] {
        return [
            "section_id": self.video?.item?.section?.id,
            "course_id": self.video?.item?.section?.course?.id,
            "current_speed": (self.playerViewController?.playbackRate).map { String($0) },
            "current_orientation": UIApplication.shared.statusBarOrientation.isLandscape ? "landscape" : "portrait",
            "current_quality": "hls",
            "current_source": self.currentSourceValue(for: self.playerViewController?.asset),
            "current_time": self.playerViewController?.currentTime.map { String($0) },
            "current_layout": self.playerViewController?.layoutState.rawValue,
        ]
    }

    private func currentSourceValue(for asset: AVAsset?) -> String? {
        guard let urlAsset = self.playerViewController?.asset as? AVURLAsset else { return nil }
        return urlAsset.url.isFileURL ? "offline" : "online"
    }

    func didConfigure() {
        self.adaptVideoContainerToVideoSize()
    }

    func didStartPlayback() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackPlay, resourceType: .video, resourceId: video.id, on: self, context: self.newTrackingContext)
    }

    func didPausePlayback() {
        guard let video = self.video else { return }
        guard let pageViewController = self.parent as? UIPageViewController else { return }
        guard pageViewController.viewControllers?.contains(self) ?? false else { return } // view controller should be currently presented
        TrackingHelper.createEvent(.videoPlaybackPause, resourceType: .video, resourceId: video.id, on: self, context: self.newTrackingContext)
    }

    func didChangePlaybackRate(from oldRate: Float, to newRate: Float) {
        UserDefaults.standard.playbackRate = newRate

        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_speed"] = nil
        context["old_speed"] = String(oldRate)
        context["new_speed"] = String(newRate)
        TrackingHelper.createEvent(.videoPlaybackChangeSpeed, resourceType: .video, resourceId: video.id, on: self, context: context)
    }

    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval) {
        guard let video = self.video else { return }

        var context = self.newTrackingContext
        context["current_time"] = nil
        context["new_current_time"] = String(newTime)
        context["old_current_time"] = String(oldTime)

        TrackingHelper.createEvent(.videoPlaybackSeek, resourceType: .video, resourceId: video.id, on: self, context: context)
    }

    func didReachEndofPlayback() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackEnd, resourceType: .video, resourceId: video.id, on: self, context: self.newTrackingContext)
    }

    func trackVideoClose() {
        guard let video = self.video else { return }
        TrackingHelper.createEvent(.videoPlaybackClose, resourceType: .video, resourceId: video.id, on: self, context: self.newTrackingContext)
    }

    func didChangeOrientation(to orientation: UIInterfaceOrientation) {
        guard let video = self.video else { return }
        guard self.isInForeground else { return }

        let verb: TrackingHelper.AnalyticsVerb = orientation.isLandscape ? .videoPlaybackDeviceOrientationLandscape : .videoPlaybackDeviceOrientationPortrait
        var context = self.newTrackingContext
        context["current_orientation"] = nil
        TrackingHelper.createEvent(verb, resourceType: .video, resourceId: video.id, on: self, context: context)
    }

    func didChangeSubtitles(from oldLanguageCode: String?, to newLanguageCode: String?) {
        guard let video = self.video else { return }
        var context = self.newTrackingContext
        context["new_subtitle_language"] = newLanguageCode ?? "off"
        TrackingHelper.createEvent(.videoPlaybackChangeSubtitle, resourceType: .video, resourceId: video.id, on: self, context: context)
    }

    func didChangeLayout(from oldLayout: LayoutState, to newLayout: LayoutState) {
        self.videoIsShownInFullScreen = newLayout == .fullScreen

        guard let video = self.video else { return }
        var context = self.newTrackingContext
        context["current_layout"] = nil
        context["new_layout"] = oldLayout.rawValue
        context["old_layout"] = newLayout.rawValue
        TrackingHelper.createEvent(.videoPlaybackChangeLayout, resourceType: .video, resourceId: video.id, on: self, context: context)
    }

}

extension VideoViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let appNavigator = self.appNavigator else { return false }
        return !appNavigator.handle(url: URL, on: self)
    }

}

extension VideoViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
