//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable type_body_length

import AVFoundation
import AVKit
import BMPlayer
import Common
import UIKit

class VideoPlayerControlView: BMPlayerControlView {

    @available(iOS 11, *)
    private lazy var routeDetector = AVRouteDetector()

    private(set) var playRate: Float = UserDefaults.standard.playbackRate
    var isOffline: Bool = false {
        didSet {
            self.offlineLabel.isHidden = !isOffline
        }
    }

    private lazy var playbackRateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.addSublayer(self.playbackRateButtonBackgroundLayer)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.9), for: .normal)
        button.addTarget(self, action: #selector(onPlaybackRateButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()

    private lazy var playbackRateButtonBackgroundLayer: CALayer = {
        let playbackRateButtonSize = CGSize(width: 40, height: 20)
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: (44 - playbackRateButtonSize.width) / 2,
                                       y: (50 - playbackRateButtonSize.height) / 2,
                                       width: playbackRateButtonSize.width,
                                       height: playbackRateButtonSize.height)
        backgroundLayer.cornerRadius = 2
        backgroundLayer.borderWidth = 1
        backgroundLayer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        return backgroundLayer
    }()

    private lazy var iPadFullScreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.9), for: .normal)
        button.addTarget(self, action: #selector(oniPadFullscreenButtonPressed), for: .touchUpInside)
        button.setImage(self.fullscreenButton.image(for: .selected), for: .selected)
        button.setImage(self.fullscreenButton.image(for: .normal), for: .normal)
        return button
    }()

    private lazy var offlineLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 2
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        label.textColor = UIColor(white: 1.0, alpha: 0.9)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = NSTextAlignment.center
        label.text = "Offline"
        return label
    }()

    @available(iOS 11, *)
    private lazy var airPlayButton: AVRoutePickerView = {
        let view = AVRoutePickerView()
        view.tintColor = .white
        view.activeTintColor = Brand.default.colors.window
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private lazy var pictureInPictureButton: UIButton = {
        let button = UIButton()
        let startPipImage = AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil).withRenderingMode(.alwaysTemplate)
        button.setImage(startPipImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(togglePictureInPictureMode), for: .touchUpInside)
        button.isHidden = !AVPictureInPictureController.isPictureInPictureSupported()
        button.isEnabled = false
        return button
    }()

    private lazy var mediaOptionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(showMediaSelection), for: .touchUpInside)
        button.setImage(R.image.videoPlayer.options(), for: .normal)
        button.tintColor = UIColor(white: 1.0, alpha: 0.9)
        return button
    }()

    private let topRightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    weak var videoController: VideoViewController?

    override func prepareUI(for resource: BMPlayerResource, selectedIndex index: Int) {
        super.prepareUI(for: resource, selectedIndex: index)

        if #available(iOS 11, *) {
            self.routeDetector.isRouteDetectionEnabled = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMultipleRoutes),
                                                   name: .AVRouteDetectorMultipleRoutesDetectedDidChange,
                                                   object: nil)
        }
    }

    override func customizeUIComponents() { // swiftlint:disable:this function_body_length
        // update top bar
        self.chooseDefinitionView.removeFromSuperview()

        let offlineLabelWrapper = UIView()
        offlineLabelWrapper.addSubview(self.offlineLabel)

        self.topMaskView.addSubview(self.topRightStackView)
        self.topRightStackView.addArrangedSubview(offlineLabelWrapper)

        if #available(iOS 11, *) {
            self.topRightStackView.addArrangedSubview(self.airPlayButton)
        }

        self.topRightStackView.addArrangedSubview(self.pictureInPictureButton)
        self.topRightStackView.addArrangedSubview(self.mediaOptionsButton)

        self.offlineLabel.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(20)
        }

        offlineLabelWrapper.snp.makeConstraints { make in
            make.leading.equalTo(self.offlineLabel.snp.leading).offset(-8)
            make.trailing.equalTo(self.offlineLabel.snp.trailing).offset(8)
            make.top.equalTo(self.offlineLabel.snp.top)
            make.bottom.equalTo(self.offlineLabel.snp.bottom)
        }

        if #available(iOS 11, *) {
            self.airPlayButton.snp.makeConstraints { make in
                make.width.equalTo(44)
                make.height.equalTo(50)
            }
        }

        self.pictureInPictureButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(50)
        }

        self.mediaOptionsButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(50)
        }

        self.topRightStackView.snp.makeConstraints { make in
            make.top.equalTo(self.topMaskView.snp.top)
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
            make.trailing.equalTo(self.topMaskView.snp.trailing)
        }

        self.titleLabel.isHidden = true

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.backButton.removeFromSuperview()
            self.titleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(self.topRightStackView.snp.centerY)
                make.leading.equalTo(self.topMaskView.snp.leading).offset(20)
            }
        }

        // update bottom bar
        self.bottomMaskView.addSubview(self.playbackRateButton)

        self.playRate = self.playRate == 0 ? 1.0 : self.playRate // playback rate can be 0 on the first time
        self.updatePlaybackRateButton()

        self.playbackRateButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(50)
            make.centerY.equalTo(self.currentTimeLabel.snp.centerY)
            make.left.equalTo(self.totalTimeLabel.snp.right).offset(5)
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.fullscreenButton.removeFromSuperview()
            self.bottomMaskView.addSubview(self.iPadFullScreenButton)

            self.iPadFullScreenButton.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerY.equalTo(self.currentTimeLabel.snp.centerY)
                make.leading.equalTo(self.playbackRateButton.snp.trailing).offset(5)
                make.trailing.equalTo(self.bottomMaskView.snp.trailing)
            }
        } else {
            self.fullscreenButton.snp.removeConstraints()
            self.fullscreenButton.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerY.equalTo(self.currentTimeLabel.snp.centerY)
                make.leading.equalTo(self.playbackRateButton.snp.trailing).offset(5)
                make.trailing.equalTo(self.bottomMaskView.snp.trailing)
            }
        }

        self.playButton.addTarget(self, action: #selector(tapPlayButton), for: .touchUpInside)
    }

    override func autoFadeOutControlViewWithAnimation() {
        guard self.player?.isPlaying == true else {
            cancelAutoFadeOutAnimation()
            return
        }

        super.autoFadeOutControlViewWithAnimation()
    }

    override func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        if let customPlayer = self.player as? CustomBMPlayer {
            if customPlayer.pictureInPictureController?.isPictureInPictureActive ?? false {
                return
            }
        }

        super.onTapGestureTapped(gesture)
    }

    override func adaptToPictureInPicturePossible(_ pictureInPicturePossible: Bool) {
        self.pictureInPictureButton.isEnabled = pictureInPicturePossible
    }

    func changeOrientation(to orientation: UIDeviceOrientation) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.backButton.isHidden = !orientation.isLandscape
            self.titleLabel.isHidden = !orientation.isLandscape
        }
    }

    @objc private func onPlaybackRateButtonPressed() {
        self.autoFadeOutControlViewWithAnimation()
        let oldPlayRate = self.playRate

        switch self.playRate {
        case 1.0:
            self.playRate = 1.25
        case 1.25:
            self.playRate = 1.5
        case 1.5:
            self.playRate = 1.75
        case 1.75:
            self.playRate = 2.0
        case 2.0:
            self.playRate = 0.7
        case 0.7:
            self.playRate = 1.0
        default:
            self.playRate = 1.0
        }

        UserDefaults.standard.playbackRate = self.playRate

        self.updatePlaybackRateButton()

        if (self.player?.playerLayer?.player?.rate ?? 0.0) > 0.0 {
            self.delegate?.controlView?(controlView: self, didChangeVideoPlaybackRate: self.playRate)
        }

        self.videoController?.trackVideoPlayRateChange(oldPlayRate: oldPlayRate, newPlayRate: self.playRate)
    }

    private func updatePlaybackRateButton() {
        self.playbackRateButton.setTitle("\(self.playRate)x", for: .normal)
    }

    @objc private func tapPlayButton() {
        if self.playButton.isSelected {
            self.videoController?.trackVideoPlay()
        } else {
            self.videoController?.trackVideoPause()
        }
    }

    @objc private func oniPadFullscreenButtonPressed() {
        self.iPadFullScreenButton.isSelected.toggle()
        self.titleLabel.isHidden = !self.iPadFullScreenButton.isSelected
        self.videoController?.setiPadFullScreenMode(self.iPadFullScreenButton.isSelected)
    }

    @objc private func togglePictureInPictureMode() {
        guard let player = self.player as? CustomBMPlayer else { return }
        player.togglePictureInPictureMode()
    }

    @objc private func showMediaSelection() {
        let mediaSelectionViewController = MediaSelectionViewController(delegate: self)

        let navigationController = UINavigationController()
        navigationController.viewControllers = [mediaSelectionViewController]
        navigationController.modalPresentationStyle = .popover
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
        popoverPresentationController?.sourceView = self.mediaOptionsButton
        popoverPresentationController?.sourceRect = self.mediaOptionsButton.bounds

        self.videoController?.present(navigationController, animated: trueUnlessReduceMotionEnabled) {
            self.cancelAutoFadeOutAnimation()
        }
    }

    @objc
    @available(iOS 11, *)
    private func handleMultipleRoutes() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.airPlayButton.isHidden = !self.routeDetector.multipleRoutesDetected
            }
        }
    }

}

extension VideoPlayerControlView: MediaSelectionDelegate {

    var currentMediaSelection: AVMediaSelection? {
        return self.videoController?.player?.avPlayer?.currentItem?.currentMediaSelection
    }

    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup) {
        self.videoController?.player?.avPlayer?.currentItem?.select(option, in: group)
    }

    func didCloseMediaSelection() {
        self.autoFadeOutControlViewWithAnimation()
    }

}

extension VideoPlayerControlView: UIPopoverPresentationControllerDelegate {

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.autoFadeOutControlViewWithAnimation()
    }

    @available(iOS, obsoleted: 13.0)
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if #available(iOS 13, *) {
            return .automatic
        } else {
            // The underlying view controller should not be removed when the media selection menu is present.
            // Therefore, we use `UIModalPresentationStyle.overFullScreen` for compact horizontal size classes.
            return traitCollection.horizontalSizeClass == .compact ? .overFullScreen : .popover
        }
    }

}

extension VideoPlayerControlView: AVRoutePickerViewDelegate {

    @available(iOS 11, *)
    public func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.cancelAutoFadeOutAnimation()
    }

    @available(iOS 11, *)
    public func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        self.autoFadeOutControlViewWithAnimation()
    }

}
