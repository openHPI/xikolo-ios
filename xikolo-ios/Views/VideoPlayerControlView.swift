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
    private(set) var playRate: Float = UserDefaults.standard.float(forKey: UserDefaultsKeys.playbackRateKey)

    override func customizeUIComponents() {
        self.chooseDefitionView.removeFromSuperview()

        self.bottomMaskView.addSubview(self.playbackRateButton)

        self.playRate = self.playRate == 0 ? 1.0 : self.playRate  // playback rate can be 0 on the first time
        self.playbackRateButton.layer.cornerRadius = 2
        self.playbackRateButton.layer.borderWidth = 1
        self.playbackRateButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        self.playbackRateButton.setTitleColor(UIColor(white: 1.0, alpha: 0.9), for: .normal)
        self.playbackRateButton.addTarget(self, action: #selector(onPlaybackRateButtonPressed), for: .touchUpInside)
        self.playbackRateButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        self.updatePlaybackRateButton()

        self.playbackRateButton.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(20)
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
