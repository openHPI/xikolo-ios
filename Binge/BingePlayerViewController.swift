//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length type_body_length

import AVFoundation
import AVKit
import MediaPlayer
import UIKit

private var playerViewControllerKVOContext = 0

public enum LayoutState: String {
    case inline
    case fullScreen
    case remote
    case pictureInPicture
}

public class BingePlayerViewController: UIViewController {

    private lazy var playerView: BingePlayerView = {
        let view = BingePlayerView()
        view.playerLayer.player = self.player
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @available(iOS, obsoleted: 13.0)
    private lazy var volumeIndicator: MPVolumeView = {
        let view = MPVolumeView()
        view.showsRouteButton = false
        view.setVolumeThumbImage(UIImage(), for: .normal)
        view.tintColor = .white
        view.isUserInteractionEnabled = false
        view.alpha = 0.001
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var loadingIndicator: BingeLoadingIndicator = {
        let indicator = BingeLoadingIndicator()
        indicator.tintColor = .white
        indicator.lineWidth = 4
        indicator.shadowRadius = 10
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var errorView: UIView = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.text = BingeLocalizedString("error-view.message", comment: "error message for assets for which the playback cannot be started")
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var controlsContainer = BingeClickThroughView()
    private lazy var controlsViewController = BingeControlsViewController(delegate: self)

    private var timeObserverToken: Any?
    private var timeStatusObservation: NSKeyValueObservation?
    private var loadedTimeRangesObservation: NSKeyValueObservation?
    private var statusObservation: NSKeyValueObservation?
    private var outputVolumeObservation: NSKeyValueObservation?
    private var pictureInPicturePossibleObservation: NSKeyValueObservation?

    @objc dynamic lazy var player = AVPlayer()

    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent",
    ]

    private var isSeeking = false

    private var pictureInPictureController: AVPictureInPictureController?
    private var pictureInPictureWasStartedAutomatically = false

    @available(iOS, obsoleted: 13.0)
    private var volumeIndicatorDispatchWorkItem: DispatchWorkItem?
    private var controlsOverlayDispatchWorkItem: DispatchWorkItem?

    private var playerWasConfigured = false
    private var didPlayToEnd = false

    private var _layoutState: LayoutState = .inline {
        didSet {
            self.delegate?.didChangeLayout(from: oldValue, to: self._layoutState)
        }
    }

    private lazy var routeDetector = AVRouteDetector()

    private var shouldToggleControls: Bool {
        return [LayoutState.inline, .fullScreen].contains(self.layoutState)
    }

    /// Determines if the player view controller is present as a child view controller or as in standalone mode (modal)
    /// - Important: Only call on main thread
    private var isStandAlone: Bool {
        return self.parent == nil && self.presentingViewController != nil
    }

    // swiftlint:disable:next identifier_name
    private var shouldEnterFullScreenModeInLandscapeOrientation: Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return false }
        return !self.isStandAlone && self.allowFullScreenMode && self.phonesWillAutomaticallyEnterFullScreenModeInLandscapeOrientation
    }

    private var isAirPlayActivated: Bool {
        return AVAudioSession.sharedInstance().currentRoute.outputs.contains { return $0.portType == .airPlay }
    }

    public var asset: AVAsset? {
        didSet {
            if let item = self.player.currentItem {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
            }

            if let asset = self.asset, asset.isPlayable {
                let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: BingePlayerViewController.assetKeysRequiredToPlay)
                self.player.replaceCurrentItem(with: item)

                if let preferredPeakBitRate = self.preferredPeakBitRate {
                    self.player.currentItem?.preferredPeakBitRate = preferredPeakBitRate
                }

                NotificationCenter.default.addObserver(self, selector: #selector(reachedPlaybackEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)

                if self.initiallyShowControls {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.showControlsOverlay()
                    }
                }
            } else {
                self.showErrorView()
            }

            self.updateMediaPlayerInfoCenter()
            self.setupMediaPlayerCommands()
        }
    }

    public var assetTitle: String? {
        didSet {
            self.controlsViewController.setTitle(self.assetTitle)
        }
    }

    public var assetSubtitle: String?

    public var posterImage: UIImage? {
        didSet {
            self.updateMediaPlayerInfoCenter()
        }
    }

    public var tintColor: UIColor = .red {
        didSet {
            self.controlsViewController.setTintColor(self.tintColor)
        }
    }

    public var layoutState: LayoutState {
        get {
            return self._layoutState
        }
        set {
            DispatchQueue.main.async {
                let newLayoutState: LayoutState = {
                    if self.isStandAlone, newValue == .inline {
                        return .fullScreen
                    } else if !self.allowFullScreenMode, newValue == .fullScreen {
                        return .inline
                    } else {
                        return newValue
                    }
                }()

                guard newLayoutState != self._layoutState else { return }
                self._layoutState = newLayoutState
                self.adaptToLayoutState()
            }
        }
    }

    public var preferredPeakBitRate: Double? {
        didSet {
            guard let preferredPeakBitRate = self.preferredPeakBitRate else { return }
            self.player.currentItem?.preferredPeakBitRate = preferredPeakBitRate
        }
    }

    public var currentTime: Double? {
        return self.player.currentItem?.currentTime().seconds
    }

    public var totalDuration: Double? {
        return self.player.currentItem?.duration.seconds
    }

    public var allowFullScreenMode = true {
        didSet {
            self.layoutState = self._layoutState
            self.controlsViewController.adaptToLayoutState(self.layoutState,
                                                           allowFullScreenMode: self.allowFullScreenMode,
                                                           isStandAlone: self.isStandAlone)
        }
    }

    // swiftlint:disable:next identifier_name
    public var phonesWillAutomaticallyEnterFullScreenModeInLandscapeOrientation = true

    public var initiallyShowControls = true
    public var startPosition: Double?

    public var playbackRate: Float = 1.0 {
        didSet {
            if self.player.timeControlStatus == .playing, self.player.rate != self.playbackRate {
                self.player.rate = self.playbackRate
            }
        }
    }

    public var videoSize: CGSize {
        return self.playerView.playerLayer.videoRect.size
    }

    public weak var delegate: BingePlayerDelegate?

    override public func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(self.playerView)
        view.addSubview(self.controlsContainer)
        view.addSubview(self.errorView)
        view.addSubview(self.loadingIndicator)

        if #available(iOS 13, *) {} else {
            view.addSubview(self.volumeIndicator)
        }

        self.controlsContainer.isHidden = true
        self.controlsContainer.translatesAutoresizingMaskIntoConstraints = false

        let layoutGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            self.playerView.topAnchor.constraint(equalTo: view.topAnchor),
            self.playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.controlsContainer.topAnchor.constraint(equalTo: view.topAnchor),
            self.controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.controlsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.errorView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            self.errorView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            self.errorView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            self.errorView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            self.loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.loadingIndicator.heightAnchor.constraint(equalToConstant: 75), // including 2 * shadowRadius
            self.loadingIndicator.widthAnchor.constraint(equalToConstant: 75), // including 2 * shadowRadius
        ])

        if #available(iOS 13, *) {} else {
            NSLayoutConstraint.activate([
                self.volumeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                self.volumeIndicator.topAnchor.constraint(equalTo: view.topAnchor),
                NSLayoutConstraint(item: self.volumeIndicator,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: self.playerView,
                                   attribute: .width,
                                   multiplier: 0.5,
                                   constant: 0),
            ])
        }

        self.view = view
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.addChild(self.controlsViewController)

        self.controlsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.controlsContainer.addSubview(self.controlsViewController.view)

        NSLayoutConstraint.activate([
            self.controlsViewController.view.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            self.controlsViewController.view.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            self.controlsViewController.view.topAnchor.constraint(equalTo: controlsContainer.topAnchor),
            self.controlsViewController.view.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor),
        ])

        self.controlsViewController.didMove(toParent: self)

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlOverlay))
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)

        if #available(iOS 13, *) {
            let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(handleHover))
            self.view.addGestureRecognizer(hoverGestureRecognizer)
        }

        if self.isAirPlayActivated {
            self.layoutState = .remote
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.controlsViewController.adaptToLayoutState(self.layoutState,
                                                       allowFullScreenMode: self.allowFullScreenMode,
                                                       isStandAlone: self.isStandAlone)

        if self.shouldEnterFullScreenModeInLandscapeOrientation, UIDevice.current.orientation.isLandscape {
            self.layoutState = .fullScreen
        }

        self.setupPlayerPeriodicTimeObserver()

        self.timeStatusObservation = self.observe(\.player.timeControlStatus, options: [.new, .initial]) { [weak self] _, _ in
            self?.reactOnTimeControlStatusChange()
        }

        self.loadedTimeRangesObservation = self.observe(\.player.currentItem?.loadedTimeRanges, options: [.new, .initial]) { [weak self] _, _ in
            self?.reactOnLoadedTimeRangesChange()
        }

        self.statusObservation = self.observe(\.player.currentItem?.status, options: [.new, .initial]) { [weak self] _, _ in
            self?.reactOnStatusChange()
        }

        if #available(iOS 13, *) {} else {
            self.outputVolumeObservation = AVAudioSession.sharedInstance().observe(\.outputVolume, options: [.new]) { [weak self] _, _ in
                self?.showVolumeIndicator()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged), name: AVAudioSession.routeChangeNotification, object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMultipleRoutes),
                                               name: .AVRouteDetectorMultipleRoutesDetectedDidChange,
                                               object: nil)
        self.routeDetector.isRouteDetectionEnabled = true
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.cleanUpPlayerPeriodicTimeObserver()
        self.timeStatusObservation?.invalidate()
        self.loadedTimeRangesObservation?.invalidate()
        self.statusObservation?.invalidate()
        self.outputVolumeObservation?.invalidate()

        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)

        NotificationCenter.default.removeObserver(self, name: .AVRouteDetectorMultipleRoutesDetectedDidChange, object: nil)
        self.routeDetector.isRouteDetectionEnabled = false
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if self.shouldEnterFullScreenModeInLandscapeOrientation {
            if self.layoutState == .inline, size.width >= size.height {
                self.layoutState = .fullScreen
            } else if self.layoutState == .fullScreen, size.width < size.height {
                self.layoutState = .inline
            }
        }

        coordinator.animateAlongsideTransition(in: nil, animation: nil) { _ in
            let currentOrientation: UIInterfaceOrientation? = {
                if #available(iOS 13, *) {
                    return self.view.window?.windowScene?.interfaceOrientation
                } else {
                    return UIApplication.shared.statusBarOrientation
                }
            }()

            self.delegate?.didChangeOrientation(to: currentOrientation)
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override public var prefersStatusBarHidden: Bool {
        return self.controlsContainer.isHidden
    }

    override public var prefersHomeIndicatorAutoHidden: Bool {
        return self.controlsContainer.isHidden
    }

    deinit {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func adaptToLayoutState() {
        self.controlsViewController.adaptToLayoutState(self.layoutState,
                                                       allowFullScreenMode: self.allowFullScreenMode,
                                                       isStandAlone: self.isStandAlone)

        if #available(iOS 13, *) {} else {
            self.volumeIndicator.isHidden = self.layoutState != .fullScreen
        }

        if self.layoutState == .pictureInPicture {
            self.hideControlsOverlay()
        } else if self.layoutState == .remote {
            self.showControlsOverlay()
        } else if self.layoutState == .inline, self.player.timeControlStatus == .paused {
            self.showControlsOverlay()
        }
    }

    private func reactOnTimeControlStatusChange() {
        let showLoadingIndicatorInLayoutState = [LayoutState.inline, .fullScreen].contains(self.layoutState)
        self.loadingIndicator.isHidden = self.player.timeControlStatus != .waitingToPlayAtSpecifiedRate || !showLoadingIndicatorInLayoutState
        self.controlsViewController.adaptToTimeControlStatus(self.player.timeControlStatus)
        self.updateMediaPlayerInfoCenter()
        self.autoHideControlsOverlay()

        if self.player.timeControlStatus == .playing, self.player.rate != self.playbackRate {
            self.player.rate = self.playbackRate
        }
    }

    private func reactOnLoadedTimeRangesChange() {
        guard let item = self.player.currentItem else { return }
        guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return }
        let availableTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
        let totalTime = CMTimeGetSeconds(item.duration)
        self.controlsViewController.adaptToBufferChange(availableTime: availableTime, totalTime: totalTime)
    }

    private func reactOnStatusChange() {
        guard let item = self.player.currentItem else {
            if playerWasConfigured {
                self.showControlsOverlay()
            }

            return
        }

        guard item.status == .readyToPlay else {
            return
        }

        self.controlsViewController.adaptToItem(item)
        self.updateMediaPlayerInfoCenter()
        self.setupPictureInPictureViewController()

        if !self.playerWasConfigured {
            if let startPosition = self.startPosition, !item.duration.isIndefinite {
                let pinnedProgress = max(0, min(startPosition / item.duration.seconds, 1))
                let newTime = CMTimeMultiplyByFloat64(item.duration, multiplier: pinnedProgress)
                self.player.seek(to: newTime)
                self.showControlsOverlay()
            }

            self.playerWasConfigured = true
            self.delegate?.didConfigure()
        }
    }

    private func reactOnPictureInPicturePossibleChange() {
        let pictureInPicturePossible = self.pictureInPictureController?.isPictureInPicturePossible ?? false
        self.controlsViewController.adaptToPictureInPicturePossible(pictureInPicturePossible)
    }

    @objc private func audioRouteChanged() {
        self.layoutState = self.isAirPlayActivated ? .remote : .inline
    }

    @objc private func handleMultipleRoutes() {
        self.controlsViewController.adaptToMultiRouteOutput(for: self.routeDetector.multipleRoutesDetected)
    }

    @objc private func reachedPlaybackEnd() {
        self.didPlayToEnd = true
        self.showControlsOverlay()
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didReachEndOfPlayback()
    }

    @objc private func toggleControlOverlay() {
        guard self.shouldToggleControls else { return }

        if self.controlsContainer.isHidden {
            self.showControlsOverlay()
        } else {
            self.hideControlsOverlay()
        }
    }

    private func setupPlayerPeriodicTimeObserver() {
        // Only add the time observer if one hasn't been created yet.
        guard self.timeObserverToken == nil else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        // Use a weak self variable to avoid a retain cycle in the block.
        self.timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let item = self?.player.currentItem else { return }
            if self?.isSeeking == true { return }
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(item.duration)
            self?.controlsViewController.adaptToTimeChange(currentTime: currentTime, totalTime: totalTime)
        }
    }

    private func cleanUpPlayerPeriodicTimeObserver() {
        guard let timeObserverToken = self.timeObserverToken else { return }
        self.player.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }

    public func showControlsOverlay() {
        guard self.controlsContainer.isHidden else { return }
        if self.pictureInPictureController?.isPictureInPictureActive ?? false { return }

        self.stopAutoHideOfControlsOverlay()

        UIView.transition(with: self.controlsContainer,
                          duration: 0.25,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: { [weak self] in
            self?.controlsContainer.isHidden = false
            self?.setNeedsStatusBarAppearanceUpdate()
            self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }, completion: { [weak self] _ in
            guard self?.layoutState != .remote else { return }
            if self?.didPlayToEnd ?? false { return }
            self?.autoHideControlsOverlay()
        })
    }

    private func hideControlsOverlay(animated: Bool = true) {
        self.stopAutoHideOfControlsOverlay()

        let animationDuration = animated ? 0.25 : 0.0
        UIView.transition(with: self.view,
                          duration: animationDuration,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: { [weak self] in
            self?.controlsContainer.isHidden = true
            self?.setNeedsStatusBarAppearanceUpdate()
            self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }, completion: nil)
    }

    @objc private func handleDoubleTap(sender: UITapGestureRecognizer) {
        if self.pictureInPictureController?.isPictureInPictureActive ?? false { return }

        let tapLocation = sender.location(in: self.view)
        let relativeHorizontalLocation = tapLocation.x / self.view.bounds.width
        if relativeHorizontalLocation < 0.4 {
            self.seekBackwards()
        } else if relativeHorizontalLocation > 0.6 {
            self.seekForwards()
        }
    }

    @available(iOS 13.0, *)
    @objc private func handleHover(sender: UIHoverGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            self.showControlsOverlay()
        case .ended:
            self.autoHideControlsOverlay(withDelay: 0)
        default:
            break
        }
    }

    private func setupPictureInPictureViewController() {
        guard self.pictureInPictureController == nil else { return }
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        self.pictureInPictureController = AVPictureInPictureController(playerLayer: self.playerView.playerLayer)
        self.pictureInPictureController?.delegate = self

        self.pictureInPicturePossibleObservation = self.pictureInPictureController?.observe(\.isPictureInPicturePossible,
                                                                                            options: [.new, .initial]) { [weak self] _, _ in
            self?.reactOnPictureInPicturePossibleChange()
        }
    }

    public func automaticallyStartPictureInPictureModeIfPossible() {
        guard let pictureInPictureController = self.pictureInPictureController else { return }
        if self.player.timeControlStatus == .paused { return }
        if pictureInPictureController.isPictureInPictureActive { return }
        pictureInPictureController.startPictureInPicture()
        self.pictureInPictureWasStartedAutomatically = true
    }

    public func automaticallyStopPictureInPictureModeIfNecessary(force: Bool = false) {
        guard let pictureInPictureController = self.pictureInPictureController else { return }
        guard pictureInPictureController.isPictureInPictureActive else { return }
        guard self.pictureInPictureWasStartedAutomatically || force else { return }
        pictureInPictureController.stopPictureInPicture()
        self.pictureInPictureWasStartedAutomatically = false
    }

    public func disconnectPlayer() {
        let isPictureInPictureActive = self.pictureInPictureController?.isPictureInPicturePossible ?? false
        if !isPictureInPictureActive {
            self.playerView.player = nil
        }
    }

    public func reconnectPlayer() {
        if self.playerView.player != self.player {
            self.playerView.player = self.player
        }
    }

    private func updateMediaPlayerInfoCenter() {
        let duration = self.player.currentItem?.duration

        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.map { CMTimeGetSeconds($0) }
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.assetTitle
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = self.assetSubtitle
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.timeControlStatus == .playing ? self.player.rate : 0
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime())
        nowPlayingInfo[MPMediaItemPropertyArtwork] = self.posterImage.map { image in
            MPMediaItemArtwork(boundsSize: image.size) { targetSize in
                return image.cropped(to: targetSize)
            }
        }

        if let urlAsset = self.asset as? AVURLAsset {
            nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = urlAsset.url
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupMediaPlayerCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.startPlayback()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pausePlayback()
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 10)]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.seekForwards()
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 10)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.seekBackwards()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            print("command center: change position")
            guard let changePositionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            guard let duration = self?.player.currentItem?.duration else { return .commandFailed }
            let progress = changePositionEvent.positionTime / CMTimeGetSeconds(duration)
            self?.seekTo(progress: progress)
            return .success
        }
    }

}

extension BingePlayerViewController: BingeMediaSelectionDataSource, BingeMediaSelectionDelegate {

    var currentMediaSelection: AVMediaSelection? {
        return self.player.currentItem?.currentMediaSelection
    }

    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup) {
        if self.currentMediaSelection?.asset?.mediaSelectionGroup(forMediaCharacteristic: .legible) == group {
            let oldLanguageCode = self.currentMediaSelection?.selectedMediaOption(in: group)?.extendedLanguageTag
            let newLanguageCode = option?.extendedLanguageTag
            self.delegate?.didChangeSubtitles(from: oldLanguageCode, to: newLanguageCode)
        }

        self.player.currentItem?.select(option, in: group)
    }

    func didCloseMediaSelection() {
        self.autoHideControlsOverlay()
    }

}

extension BingePlayerViewController: BingeControlDelegate {

    func stopAutoHideOfControlsOverlay() {
        self.controlsOverlayDispatchWorkItem?.cancel()
    }

    func showMediaSelection(for sourceView: UIView) {
        self.stopAutoHideOfControlsOverlay()

        let mediaSelectionViewController = BingeMediaSelectionViewController(delegate: self)

        let navigationController = UINavigationController()
        navigationController.viewControllers = [mediaSelectionViewController]
        navigationController.modalPresentationStyle = .popover
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.barTintColor = UIColor(white: 0.1, alpha: 1.0)
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
        ]

        let popoverPresentationController = navigationController.popoverPresentationController
        popoverPresentationController?.delegate = self
        popoverPresentationController?.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        popoverPresentationController?.permittedArrowDirections = .up
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceView.bounds

        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    var fullscreenTitle: String? {
        return self.assetTitle
    }

    public func startPlayback() {
        guard self.asset?.isPlayable ?? false else { return }
        guard self.player.timeControlStatus == .paused else { return }

        try? AVAudioSession.sharedInstance().setActive(true)

        if self.didPlayToEnd {
            let newTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.player.seek(to: newTime)
            self.didPlayToEnd = false
        }

        self.player.play()
        self.autoHideControlsOverlay()
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didStartPlayback()
    }

    public func pausePlayback() {
        if self.player.timeControlStatus == .paused { return }

        self.player.pause()
        self.stopAutoHideOfControlsOverlay()
        self.showControlsOverlay()
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didPausePlayback()

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func willSeekTo(progress: Double) {
        guard let item = self.player.currentItem else { return }
        self.isSeeking = true
        let seekTime = CMTimeGetSeconds(CMTimeMultiplyByFloat64(item.duration, multiplier: progress))
        let totalTime = CMTimeGetSeconds(item.duration)
        self.controlsViewController.adaptToTimeChange(currentTime: seekTime, totalTime: totalTime, isManualSeekPosition: true)
    }

    func seekTo(progress: Double) {
        guard let duration = self.player.currentItem?.duration else { return }
        let currentTime = self.player.currentTime()
        let newTime = CMTimeMultiplyByFloat64(duration, multiplier: progress)
        self.player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            self.isSeeking = false
            self.autoHideControlsOverlay()
            self.updateMediaPlayerInfoCenter()
            self.delegate?.didSeek(from: CMTimeGetSeconds(currentTime), to: CMTimeGetSeconds(newTime))
        }
    }

    func seekForwards() {
        self.seekBy(offset: 10)
    }

    func seekBackwards() {
        self.seekBy(offset: -10)
    }

    private func seekBy(offset: TimeInterval) {
        let diff = CMTime(seconds: offset, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let currentTime = self.player.currentTime()

        let zero = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        var newTime = CMTimeAdd(currentTime, diff)
        newTime = CMTimeMaximum(zero, newTime)

        if let duration = self.player.currentItem?.duration {
            newTime = CMTimeMinimum(duration, newTime)
        }

        guard CMTimeCompare(currentTime, newTime) != 0 else { return }

        self.player.seek(to: newTime) { _ in
            self.updateMediaPlayerInfoCenter()
            self.delegate?.didSeek(from: CMTimeGetSeconds(currentTime), to: CMTimeGetSeconds(newTime))
        }
    }

    func toggleFullScreenMode() {
        if self.shouldEnterFullScreenModeInLandscapeOrientation, self.layoutState == .fullScreen, UIDevice.current.orientation.isLandscape {
            let value = UIDeviceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else if self.layoutState == .inline {
            self.layoutState = .fullScreen
        } else {
            self.layoutState = .inline
        }
    }

    func togglePictureInPictureMode() {
        guard let pictureInPictureController = self.pictureInPictureController else { return }

        if pictureInPictureController.isPictureInPictureActive {
            pictureInPictureController.stopPictureInPicture()
        } else {
            pictureInPictureController.startPictureInPicture()
        }
    }

    func showErrorView() {
        self.hideControlsOverlay(animated: false)
        self.loadingIndicator.isHidden = true
        self.errorView.isHidden = false
    }

    func dismissPlayer() {
        self.pausePlayback()
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}

extension BingePlayerViewController {

    @available(iOS, obsoleted: 13.0)
    private func showVolumeIndicator() {
        UIView.transition(with: self.volumeIndicator,
                          duration: 0.25,
                          options: [.transitionCrossDissolve, .curveEaseInOut],
                          animations: { [weak self] in
            self?.volumeIndicator.alpha = 1
        }, completion: { [weak self] _ in
            self?.autoHideVolumeIndicator()
        })
    }

    @available(iOS, obsoleted: 13.0)
    private func autoHideVolumeIndicator() {
        self.volumeIndicatorDispatchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let indicator = self?.volumeIndicator else { return }
            UIView.transition(with: indicator,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .curveEaseInOut],
                              animations: { [weak self] in
                self?.volumeIndicator.alpha = 0.001
            }, completion: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: workItem)
        self.volumeIndicatorDispatchWorkItem = workItem
    }

    private func autoHideControlsOverlay(withDelay delay: TimeInterval = 5.0) {
        guard self.player.timeControlStatus == .playing else { return }
        guard self.presentedViewController == nil else { return } // Shows media selection options
        guard self.shouldToggleControls else { return }

        self.stopAutoHideOfControlsOverlay()

        let workItem = DispatchWorkItem { [weak self] in
            guard let view = self?.view else { return }
            UIView.transition(with: view,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .curveEaseInOut],
                              animations: { [weak self] in
                self?.controlsContainer.isHidden = true
                self?.setNeedsStatusBarAppearanceUpdate()
                self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }, completion: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: workItem)
        self.controlsOverlayDispatchWorkItem = workItem
    }

}

extension BingePlayerViewController: UIPopoverPresentationControllerDelegate {

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.autoHideControlsOverlay()
    }

}

extension BingePlayerViewController: AVPictureInPictureControllerDelegate {

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                           restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }

    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.layoutState = .pictureInPicture
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        self.layoutState = .inline
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.layoutState = .inline
    }

}

extension BingePlayerViewController: BingePlaybackRateDelegate {

    var currentRate: Float {
        return self.playbackRate
    }

    func changeRate(to rate: Float) {
        self.delegate?.didChangePlaybackRate(from: self.playbackRate, to: rate)
        self.playbackRate = rate
    }

}

extension BingePlayerViewController: AVRoutePickerViewDelegate {

    public func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.stopAutoHideOfControlsOverlay()
    }

    public func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.autoHideControlsOverlay()
    }

}
