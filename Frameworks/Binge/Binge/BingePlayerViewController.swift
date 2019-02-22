//
//  BingeVideoViewController.swift
//  Binge
//
//  Created by Max Bothe on 21.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import AVFoundation
import AVKit
import MediaPlayer
import UIKit

private var playerViewControllerKVOContext = 0

public enum LayoutState {
    case inline
    case fullscreen
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

    private lazy var volumeIndicator: MPVolumeView = {
        let view = MPVolumeView()
        view.showsRouteButton = false
        view.setVolumeThumbImage(UIImage(), for: .normal)
        view.tintColor = .white
        view.isUserInteractionEnabled = false
        view.alpha = 0.001
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var loadingIndicator: BingeLoadingIndicator = {
        let indicator = BingeLoadingIndicator()
        indicator.tintColor = .white
        indicator.lineWidth = 4
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var controlsContainer = BingeClickThroughView()
    private lazy var controlsViewController = BingeControlsViewController(delegate: self)

    @objc dynamic lazy var player = AVPlayer()

    var timeObserverToken: Any?

    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent",
    ]

    private var pictureInPictureController: AVPictureInPictureController?

    private var volumeIndicatorDispatchWorkItem: DispatchWorkItem?
    private var controlsOverlayDispatchWorkItem: DispatchWorkItem?

    public var asset: AVAsset? {
        didSet {
            if let item = self.player.currentItem {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
            }

            if let asset = self.asset {
                let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: BingePlayerViewController.assetKeysRequiredToPlay)
                self.player.replaceCurrentItem(with: item)
                NotificationCenter.default.addObserver(self, selector: #selector(reachedPlaybackEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)
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

    private var playerWasConfigured = false
    private var didPlayToEnd = false

    private var _layoutState: LayoutState = .inline
    public var layoutState: LayoutState {
        get {
            return self._layoutState
        }
        set {
            let newLayoutState: LayoutState = {
                if self.isStandAlone, newValue == .inline {
                    return .fullscreen
                } else if !self.allowFullScreenMode, newValue == .fullscreen {
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

    private func adaptToLayoutState() {
        DispatchQueue.main.async {
            self.controlsViewController.adaptToLayoutState(self.layoutState,
                                                           allowFullScreenMode: self.allowFullScreenMode,
                                                           isStandAlone: self.isStandAlone)
            if self.layoutState == .pictureInPicture {
                self.hideControlsOverlay()
            } else if self.layoutState == .remote {
                self.showControlsOverlay()
            } else if self.player.timeControlStatus == .paused {
                self.showControlsOverlay() /// XXX: why here?
            }

            self.delegate?.didChangeLayoutState(to: self.layoutState)

            guard !self.isStandAlone else { return }

            if let fullscreenPresenter = self.fullscreenPresenter, self.layoutState != .fullscreen {
                fullscreenPresenter.close()
                self.fullscreenPresenter = nil
            } else if self.layoutState == .fullscreen {
                self.fullscreenPresenter = BingeFullScreenPresenter(for: self)
                self.fullscreenPresenter?.open()
            }
        }
    }

    public var allowFullScreenMode: Bool = true {
        didSet {
            self.layoutState = self._layoutState
            self.controlsViewController.adaptToLayoutState(self.layoutState,
                                                           allowFullScreenMode: self.allowFullScreenMode,
                                                           isStandAlone: self.isStandAlone)
        }
    }

    private var isStandAlone: Bool {
        return self.parent == nil && self.presentingViewController != nil
    }

    public var phonesWillAutomaticallyEnterFullScreenModeInLandscapeOrientation = true
    private var shouldEnterFullScreenModeInLandscapeOrientation: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && !self.isStandAlone && self.allowFullScreenMode && self.phonesWillAutomaticallyEnterFullScreenModeInLandscapeOrientation
    }

    private var fullscreenPresenter: BingeFullScreenPresenter?

    @available(iOS 11, *)
    private lazy var routeDetector = AVRouteDetector()

    public var wantsAutoPlay = false
    public var startProgress: Float?

    public var playbackRate: Float = 1.0 {
        didSet {
            if self.player.timeControlStatus == .playing, self.player.rate != self.playbackRate {
                self.player.rate = self.playbackRate
            }

            self.delegate?.didChangePlaybackRate(from: oldValue, to: self.playbackRate)
        }
    }

    public weak var delegate: BingePlayerDelegate?

    private var isAirPlayActivated: Bool {
        return AVAudioSession.sharedInstance().currentRoute.outputs.contains { return $0.portType == .airPlay }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override public func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(self.playerView)
        view.addSubview(self.controlsContainer)
        view.addSubview(self.volumeIndicator)
        view.addSubview(self.loadingIndicator)

        self.controlsContainer.isHidden = true
        self.controlsContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.playerView.topAnchor.constraint(equalTo: view.topAnchor),
            self.playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.controlsContainer.topAnchor.constraint(equalTo: view.topAnchor),
            self.controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.controlsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.volumeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.volumeIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            NSLayoutConstraint(item: self.volumeIndicator, attribute: .width, relatedBy: .equal, toItem: self.playerView, attribute: .width, multiplier: 0.5, constant: 0),
            self.loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.loadingIndicator.heightAnchor.constraint(equalToConstant: 55),
            self.loadingIndicator.widthAnchor.constraint(equalToConstant: 55),
        ])

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
            self.controlsViewController.view.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor)
        ])

        self.controlsViewController.didMove(toParent: self)

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleControlOverlay))
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)

        if #available(iOS 11, *) {
            self.routeDetector.isRouteDetectionEnabled = true
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.controlsViewController.adaptToLayoutState(self.layoutState,
                                                       allowFullScreenMode: self.allowFullScreenMode,
                                                       isStandAlone: self.isStandAlone)

        if self.shouldEnterFullScreenModeInLandscapeOrientation, UIDevice.current.orientation.isLandscape {
            self.layoutState = .fullscreen
        }

        self.setupPlayerPeriodicTimeObserver()

        self.addObserver(self, forKeyPath: "player.timeControlStatus", options: [.new, .initial], context: &playerViewControllerKVOContext)
        self.addObserver(self, forKeyPath: "player.currentItem.loadedTimeRanges", options: [.new, .initial], context: &playerViewControllerKVOContext)
        self.addObserver(self, forKeyPath: "player.currentItem.status", options: [.new, .initial], context: &playerViewControllerKVOContext)

        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: [.new], context: &playerViewControllerKVOContext)

        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged), name: AVAudioSession.routeChangeNotification, object: nil)
        if self.isAirPlayActivated {
            self.layoutState = .remote
        }

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

        if #available(iOS 11, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleMultipleRoutes), name: .AVRouteDetectorMultipleRoutesDetectedDidChange, object: nil)
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.cleanUpPlayerPeriodicTimeObserver()

        self.removeObserver(self, forKeyPath: "player.timeControlStatus", context: &playerViewControllerKVOContext)
        self.removeObserver(self, forKeyPath: "player.currentItem.loadedTimeRanges", context: &playerViewControllerKVOContext)
        self.removeObserver(self, forKeyPath: "player.currentItem.status", context: &playerViewControllerKVOContext)

        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume", context: &playerViewControllerKVOContext)

        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)

        if #available(iOS 11, *) {
            NotificationCenter.default.removeObserver(self, name: .AVRouteDetectorMultipleRoutesDetectedDidChange, object: nil)
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerViewControllerKVOContext else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        if keyPath == "player.timeControlStatus" {
            let status = self.player.timeControlStatus
            self.loadingIndicator.isHidden = status != .waitingToPlayAtSpecifiedRate
            self.controlsViewController.adaptToTimeControlStatus(status)
            self.updateMediaPlayerInfoCenter()
            self.autoHideControlsOverlay()

            if self.player.timeControlStatus == .playing, self.player.rate != self.playbackRate {
                self.player.rate = self.playbackRate
            }
        } else if keyPath == "player.currentItem.loadedTimeRanges" {
            guard let item = self.player.currentItem else { return }
            guard let timeRange = item.loadedTimeRanges.first?.timeRangeValue else { return }
            let availableTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
            let totalTime = CMTimeGetSeconds(item.duration)
            self.controlsViewController.adaptToBufferChange(availableTime: availableTime, totalTime: totalTime)
        } else if keyPath == "player.currentItem.status" {
            guard let item = self.player.currentItem else {
                self.showControlsOverlay()
                return
            }

            guard item.status == .readyToPlay else {
                return
            }

            self.controlsViewController.adaptToItem(item)
            self.updateMediaPlayerInfoCenter()
            self.setupPictureInPictureViewController()

            if !self.playerWasConfigured {
                if let progress = self.startProgress, !item.duration.isIndefinite {
                    let pinnedProgress = max(0, min(Float64(progress), 1))
                    let newTime = CMTimeMultiplyByFloat64(item.duration, multiplier: pinnedProgress)
                    self.player.seek(to: newTime)
                }

                if self.wantsAutoPlay {
                    try? AVAudioSession.sharedInstance().setActive(true)
                    self.player.play()
                    self.hideControlsOverlay()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.showControlsOverlay()
                    }
                }

                self.playerWasConfigured = true
            }

        } else if keyPath == "pictureInPicturePossible" {
            let pictureInPicturePossible = self.pictureInPictureController?.isPictureInPicturePossible ?? false
            self.controlsViewController.adaptToPictureInPicturePossible(pictureInPicturePossible)
        } else if keyPath == "outputVolume" {
            self.showVolumeIndicator()
        }
    }

    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override public var prefersStatusBarHidden: Bool {
        return self.controlsContainer.isHidden || (UIDevice.current.userInterfaceIdiom == .phone && UIDevice.current.orientation.isLandscape)
    }

    override public var prefersHomeIndicatorAutoHidden: Bool {
        return self.controlsContainer.isHidden
    }

    @objc private func audioRouteChanged() {
        self.layoutState = self.isAirPlayActivated ? .remote : .inline
    }

    @objc
    @available(iOS 11, *)
    private func handleMultipleRoutes() {
        self.controlsViewController.adaptToMultiRouteOutput(for: self.routeDetector.multipleRoutesDetected)
    }

    @objc private func reachedPlaybackEnd() {
        self.didPlayToEnd = true
        self.showControlsOverlay()
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didReachEndofPlayback()
    }

    @objc private func orientationChanged() {
        let currentOrientation = UIDevice.current.orientation
        self.delegate?.didChangeOrientation(to: currentOrientation)

        guard self.shouldEnterFullScreenModeInLandscapeOrientation else { return }

        if self.layoutState == .inline, currentOrientation.isLandscape {
            self.layoutState = .fullscreen
        } else if self.layoutState == .fullscreen, currentOrientation == .portrait {
            self.layoutState = .inline
        }
    }

    @objc private func toggleControlOverlay() {
        guard self.layoutState != .remote, self.layoutState != .pictureInPicture else { return }

        if self.controlsContainer.isHidden {
            self.showControlsOverlay()
        } else {
            self.hideControlsOverlay()
        }
    }

    private func setupPlayerPeriodicTimeObserver() {
        // Only add the time observer if one hasn't been created yet.
        guard self.timeObserverToken == nil else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        // Use a weak self variable to avoid a retain cycle in the block.
        self.timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
            [weak self] time in
            guard let item = self?.player.currentItem else { return }
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

    private func showControlsOverlay() {
        guard self.controlsContainer.isHidden else { return }
        if self.pictureInPictureController?.isPictureInPictureActive ?? false { return }

        self.controlsOverlayDispatchWorkItem?.cancel()

        UIView.transition(with: self.controlsContainer,
                          duration: 0.25,
                          options: [.transitionCrossDissolve, .curveEaseInOut], animations: { [weak self] in
            self?.controlsContainer.isHidden = false
            self?.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 11, *) {
                self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
        }, completion: { [weak self] finished in
            guard self?.layoutState != .remote else { return }
            if self?.didPlayToEnd ?? false { return }
            self?.autoHideControlsOverlay()
        })
    }

    private func hideControlsOverlay() {
        self.controlsOverlayDispatchWorkItem?.cancel()

        UIView.transition(with: self.view,
                          duration: 0.25,
                          options: [.transitionCrossDissolve, .curveEaseInOut], animations: { [weak self] in
            self?.controlsContainer.isHidden = true
            self?.setNeedsStatusBarAppearanceUpdate()
            if #available(iOS 11, *) {
                self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
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

    private func setupPictureInPictureViewController() {
        guard self.pictureInPictureController == nil else { return }
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        self.pictureInPictureController = AVPictureInPictureController(playerLayer: self.playerView.playerLayer)
        self.pictureInPictureController?.delegate = self
        self.pictureInPictureController?.addObserver(self, forKeyPath: "pictureInPicturePossible", options: [.new, .initial], context: &playerViewControllerKVOContext)
    }

    private func updateMediaPlayerInfoCenter() {
        let duration = self.player.currentItem?.duration

        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.map { CMTimeGetSeconds($0) }
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.assetTitle
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = self.assetSubtitle
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.timeControlStatus == .playing ? self.player.rate : 0
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupMediaPlayerCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] event in
            self?.startPlayback()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pausePlayback()
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: 5)]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            self?.seekForwards()
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: 5)]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
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

extension BingePlayerViewController: BingeMediaSelectionDelegate {

    var currentMediaSelection: AVMediaSelection? {
        return self.player.currentItem?.currentMediaSelection
    }

    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup) {
        self.player.currentItem?.select(option, in: group)
    }

    func didCloseMediaSelection() {
        self.autoHideControlsOverlay()
    }

}

extension BingePlayerViewController: BingeControlDelegate {

    func showMediaSelection(for sourceView: UIView) {
        self.controlsOverlayDispatchWorkItem?.cancel()

        let mediaSelectionViewController = BingeMediaSelectionViewController(delegate: self)

        let navigationController = UINavigationController()
        navigationController.viewControllers = [mediaSelectionViewController]
        navigationController.modalPresentationStyle = self.shouldEnterFullScreenModeInLandscapeOrientation ? .currentContext : .popover
        navigationController.navigationBar.barStyle = .blackOpaque
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

        self.present(navigationController, animated: true)
    }

    var fullscreenTitle: String? {
        return self.assetTitle
    }

    public func startPlayback() {
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
        guard self.player.timeControlStatus != .paused else { return }

        self.player.pause()
        self.controlsOverlayDispatchWorkItem?.cancel()
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didPausePlayback()

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func seekTo(progress: Double) {
        guard let duration = self.player.currentItem?.duration else { return }
        let newTime = CMTimeMultiplyByFloat64(duration, multiplier: progress)
        self.player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        self.autoHideControlsOverlay()
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didSeek(from: CMTimeGetSeconds(self.player.currentTime()), to: CMTimeGetSeconds(newTime))
    }

    func seekForwards() {
        self.seekBy(offset: 5)
    }

    func seekBackwards() {
        self.seekBy(offset: -5)
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

        self.player.seek(to: newTime)
        self.updateMediaPlayerInfoCenter()
        self.delegate?.didSeek(from: CMTimeGetSeconds(currentTime), to: CMTimeGetSeconds(newTime))
    }

    func toggleFullScreenMode() {
        if self.shouldEnterFullScreenModeInLandscapeOrientation, self.layoutState == .fullscreen, UIDevice.current.orientation.isLandscape {
            let value = UIDeviceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else if self.layoutState == .inline {
            self.layoutState = .fullscreen
        } else {
            self.layoutState = .inline
        }
    }

    func togglePictureInPictureMode() {
        guard let pictureInPictureController = self.pictureInPictureController else { return }

        print("is possible \(pictureInPictureController.isPictureInPicturePossible)")
        if pictureInPictureController.isPictureInPictureActive {
            pictureInPictureController.stopPictureInPicture()
        } else {
            pictureInPictureController.startPictureInPicture()
        }
    }

    func dismissPlayer() {
        self.pausePlayback()
        self.dismiss(animated: true)
    }

}

extension BingePlayerViewController {

    private func showVolumeIndicator() {
        UIView.transition(with: self.volumeIndicator,
                          duration: 0.25,
                          options: [.transitionCrossDissolve, .curveEaseInOut], animations: { [weak self] in
            self?.volumeIndicator.alpha = 1
        }, completion: { [weak self] finished in
            self?.autoHideVolumenIndicator()
        })
    }

    private func autoHideVolumenIndicator() {
        self.volumeIndicatorDispatchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let indicator = self?.volumeIndicator else { return }
            UIView.transition(with: indicator,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .curveEaseInOut], animations: { [weak self] in
                self?.volumeIndicator.alpha = 0.001
            }, completion: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: workItem)
        self.volumeIndicatorDispatchWorkItem = workItem
    }

    private func autoHideControlsOverlay(withDelay delay: TimeInterval = 7.0) {
        guard self.player.timeControlStatus == .playing else { return }
        guard self.presentedViewController == nil else { return } // Shows media selection options
        guard self.layoutState != .remote else { return }

        self.controlsOverlayDispatchWorkItem?.cancel()
    
        let workItem = DispatchWorkItem { [weak self] in
            guard let view = self?.view else { return }
            UIView.transition(with: view,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .curveEaseInOut], animations: { [weak self] in
                self?.controlsContainer.isHidden = true
                self?.setNeedsStatusBarAppearanceUpdate()
                if #available(iOS 11, *) {
                    self?.setNeedsUpdateOfHomeIndicatorAutoHidden()
                }
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

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        //Update video controls of main player to reflect the current state of the video playback.
        //You may want to update the video scrubber position.
        print("restoreUserInterfaceForPictureInPictureStopWithCompletionHandler")
        completionHandler(true)
    }

    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //Handle PIP will start event
        print("pictureInPictureControllerWillStartPictureInPicture")
        self.layoutState = .pictureInPicture
    }

    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //Handle PIP did start event
        print("pictureInPictureControllerDidStartPictureInPicture")
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        //Handle PIP failed to start event
        print("failedToStartPictureInPictureWithError")
        self.layoutState = .inline
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //Handle PIP will stop event
        print("pictureInPictureControllerWillStopPictureInPicture")
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //Handle PIP did start event
        print("pictureInPictureControllerDidStopPictureInPicture")
        self.layoutState = .inline
    }

}

extension BingePlayerViewController: BingePlaybackRateDelegate {

    var currentRate: Float {
        return self.playbackRate
    }

    func changeRate(to rate: Float) {
        self.playbackRate = rate
    }

}

extension BingePlayerViewController: AVRoutePickerViewDelegate {

    @available(iOS 11, *)
    public func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.controlsOverlayDispatchWorkItem?.cancel()
    }

    @available(iOS 11, *)
    public func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.autoHideControlsOverlay()
    }

}
