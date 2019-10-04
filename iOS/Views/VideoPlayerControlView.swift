//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BMPlayer
import Foundation
import UIKit

class CustomBMPlayer: BMPlayer {

    weak var videoController: VideoViewController?

    override func seek(_ to: TimeInterval, completion: (() -> Void)? = nil) { // swiftlint:disable:this identifier_name
        let from = self.playerLayer?.player?.currentTime().seconds
        super.seek(to, completion: completion)
        self.videoController?.trackVideoSeek(from: from, to: to)
    }

}

class VideoPlayerControlView: BMPlayerControlView {

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

    private let topRightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    weak var videoController: VideoViewController?

    override func customizeUIComponents() { // swiftlint:disable:this function_body_length
        // update top bar
        self.chooseDefitionView.removeFromSuperview()

        self.topMaskView.addSubview(self.topRightStackView)
        self.topRightStackView.addArrangedSubview(self.offlineLabel)

        self.offlineLabel.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(20)
        }

        self.topRightStackView.snp.makeConstraints { make in
            make.top.equalTo(self.topMaskView.snp.top).offset(16)
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
            make.trailing.equalTo(self.topMaskView.snp.trailing).offset(-20)
        }

        self.titleLabel.isHidden = true

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.backButton.removeFromSuperview()
            self.titleLabel.snp.makeConstraints { make in
                make.top.equalTo(self.topMaskView.snp.top).offset(16)
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

    func changeOrientation(to orientation: UIDeviceOrientation) {
        self.backButton.isHidden = !orientation.isLandscape

        if UIDevice.current.userInterfaceIdiom == .phone {
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

}
