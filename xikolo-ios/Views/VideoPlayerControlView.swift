//
//  VideoPlayerControlView.swift
//  xikolo-ios
//
//  Created by Max Bothe on 21/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BMPlayer
import UIKit

class VideoPlayerControlView: BMPlayerControlView {

    private var playbackRateButton = UIButton(type: .custom)
    private var offlineLabel = UILabel()
    private(set) var playRate: Float = UserDefaults.standard.float(forKey: UserDefaultsKeys.playbackRateKey)

    override func customizeUIComponents() {
        // update top bar
        self.chooseDefitionView.removeFromSuperview()

        self.topMaskView.addSubview(self.offlineLabel)
        self.offlineLabel.layer.cornerRadius = 2
        self.offlineLabel.layer.borderWidth = 1
        self.offlineLabel.layer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        self.offlineLabel.textColor = UIColor(white: 1.0, alpha: 0.9)
        self.offlineLabel.font = UIFont.systemFont(ofSize: 12)
        self.offlineLabel.textAlignment = NSTextAlignment.center
        self.offlineLabel.text = "Offline"

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.backButton.removeFromSuperview()
            self.titleLabel.removeFromSuperview()

            self.offlineLabel.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(20)
                make.top.equalTo(self.topMaskView.snp.top).offset(5)
                make.right.equalTo(self.topMaskView.snp.right).offset(-20)
            }
        } else {
            self.offlineLabel.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(20)
                make.centerY.equalTo(self.titleLabel)
                make.left.equalTo(self.titleLabel.snp.right).offset(5)
                make.right.equalTo(self.topMaskView.snp.right).offset(-20)
            }
        }

        // update bottom bar
        self.bottomMaskView.addSubview(self.playbackRateButton)

        let playbackRateButtonSize = CGSize(width: 40, height: 20)
        self.playRate = self.playRate == 0 ? 1.0 : self.playRate  // playback rate can be 0 on the first time
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRect(x: (44 - playbackRateButtonSize.width)/2,
                                       y: (50 - playbackRateButtonSize.height)/2,
                                       width: playbackRateButtonSize.width,
                                       height: playbackRateButtonSize.height)
        backgroundLayer.cornerRadius = 2
        backgroundLayer.borderWidth = 1
        backgroundLayer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        self.playbackRateButton.layer.addSublayer(backgroundLayer)
        self.playbackRateButton.setTitleColor(UIColor(white: 1.0, alpha: 0.9), for: .normal)
        self.playbackRateButton.addTarget(self, action: #selector(onPlaybackRateButtonPressed), for: .touchUpInside)
        self.playbackRateButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.updatePlaybackRateButton()

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.playbackRateButton.snp.makeConstraints { make in
                make.width.equalTo(44)
                make.height.equalTo(50)
                make.centerY.equalTo(self.currentTimeLabel)
                make.left.equalTo(self.totalTimeLabel.snp.right).offset(5)
                make.right.equalTo(self.bottomMaskView.snp.right).offset(-10)
            }

            self.fullscreenButton.removeFromSuperview()
        } else {
            self.playbackRateButton.snp.makeConstraints { make in
                make.width.equalTo(44)
                make.height.equalTo(50)
                make.centerY.equalTo(self.currentTimeLabel)
                make.left.equalTo(self.totalTimeLabel.snp.right).offset(5)
            }

            self.fullscreenButton.snp.removeConstraints()
            self.fullscreenButton.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerY.equalTo(self.currentTimeLabel)
                make.left.equalTo(self.playbackRateButton.snp.right).offset(5)
                make.right.equalTo(self.bottomMaskView.snp.right)
            }
        }
    }

    func setOffline(_ isOffline: Bool) {
        self.offlineLabel.isHidden = !isOffline
    }

    func changeOrientation(to orientation: UIDeviceOrientation) {
        self.backButton.isHidden = !orientation.isLandscape
        self.titleLabel.isHidden = !orientation.isLandscape
    }

    @objc private func onPlaybackRateButtonPressed() {
        self.autoFadeOutControlViewWithAnimation()
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

        UserDefaults.standard.set(self.playRate, forKey: UserDefaultsKeys.playbackRateKey)
        UserDefaults.standard.synchronize()

        self.updatePlaybackRateButton()
        self.delegate?.controlView?(controlView: self, didChangeVideoPlaybackRate: self.playRate)
    }

    private func updatePlaybackRateButton() {
        self.playbackRateButton.setTitle("\(self.playRate)x", for: .normal)
    }

}
