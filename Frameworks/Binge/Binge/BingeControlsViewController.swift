//
//  BingeControlsViewController.swift
//  Binge
//
//  Created by Max Bothe on 21.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

class BingeControlsViewController: UIViewController {

    private lazy var bufferProgressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor(white: 0.9, alpha: 1.0)
        progress.trackTintColor = UIColor(white: 0.6, alpha: 1.0)
        progress.progress = 0
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    private lazy var timeSlider: BingeTimeSlider = {
        let slider = BingeTimeSlider()
        slider.isContinuous = false
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .clear
        slider.tintColor = .red
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.0

        slider.isEnabled = false
        slider.translatesAutoresizingMaskIntoConstraints = false

        slider.setThumbImage(UIImage.bingeImage(named: "thumb-small"), for: .normal)
        slider.setThumbImage(UIImage.bingeImage(named: "thumb-big"), for: .highlighted)
        slider.addTarget(self, action: #selector(changeProgress), for: .valueChanged)

        return slider
    }()

    private lazy var currentTimeView: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0:00"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var totalTimeView: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0:00"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var fullScreenButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage.bingeImage(named: "ios-expand"), for: .normal)
        button.setImage(UIImage.bingeImage(named: "ios-contract"), for: .selected)
        button.addTarget(self, action: #selector(toggleFullScreenMode), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var emptyView: UIView = { // To have at least one view in the top left stackview
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage.bingeImage(named: "ios-close"), for: .normal)
        button.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var offlineLabel: UILabel = {
        let label = BingePaddedLabel()
        label.text = "Offline"
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textAlignment = .center
        label.textColor = .white
        label.isHidden = true
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
        label.textColor = .white
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority.defaultLow - 1, for: .horizontal)
        return label
    }()

    private lazy var pictureInPictureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let startPipImage = AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil).withRenderingMode(.alwaysTemplate)
        button.setImage(startPipImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(togglePictureInPictureMode), for: .touchUpInside)
        button.isHidden = !AVPictureInPictureController.isPictureInPictureSupported()
        button.isEnabled = false
        return button
    }()

    @available(iOS 11, *)
    private lazy var airPlayButton: AVRoutePickerView = {
        let view = AVRoutePickerView()
        view.tintColor = .white
        view.activeTintColor = .red // TODO: change?
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self.delegate
        view.isHidden = true
        return view
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage.bingeImage(named: "ios-options"), for: .normal)
        button.addTarget(self, action: #selector(showMediaSelection), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var topBarLeftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var topBarRightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var bottomBarRightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage.bingeImage(named: "ios-play"), for: .normal)
        button.setImage(UIImage.bingeImage(named: "ios-pause"), for: .selected)
        button.addTarget(self, action: #selector(playPauseVideo), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var seekForwardButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage.bingeImage(named: "ios-refresh"), for: .normal)
        button.addTarget(self, action: #selector(seekForwards), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var seekBackwardButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage.bingeImage(named: "ios-refresh"), for: .normal)
        button.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        button.addTarget(self, action: #selector(seekBackwards), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let delegate: BingeControlDelegate & AVRoutePickerViewDelegate

    init(delegate: BingeControlDelegate & AVRoutePickerViewDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = BingeClickThroughView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.75)

        self.addSubviews(to: view)
        self.addConstraints(with: view)

        self.view = view
    }

    private func addSubviews(to parent: UIView) {
        parent.addSubview(self.bufferProgressView)
        parent.addSubview(self.timeSlider)
        parent.addSubview(self.currentTimeView)
        parent.addSubview(self.totalTimeView)
        parent.addSubview(self.bottomBarRightStackView)
        self.bottomBarRightStackView.addArrangedSubview(self.fullScreenButton)

        parent.addSubview(self.topBarLeftStackView)
        self.topBarLeftStackView.addArrangedSubview(self.emptyView)
        self.topBarLeftStackView.addArrangedSubview(self.closeButton)
        self.topBarLeftStackView.addArrangedSubview(self.offlineLabel)
        parent.addSubview(self.titleView)
        parent.addSubview(self.topBarRightStackView)
        self.topBarRightStackView.addArrangedSubview(self.pictureInPictureButton)
        if #available(iOS 11, *) {
            self.topBarRightStackView.addArrangedSubview(self.airPlayButton)
        }
        self.topBarRightStackView.addArrangedSubview(self.settingsButton)

        parent.addSubview(self.playPauseButton)
        parent.addSubview(self.seekForwardButton)
        parent.addSubview(self.seekBackwardButton)
    }

    private func addConstraints(with parent: UIView) {
        let padding: CGFloat = 12
        let parentMargins: UILayoutGuide = {
            if #available(iOS 11, *) {
                return parent.safeAreaLayoutGuide
            } else {
                return parent.layoutMarginsGuide
            }
        }()

        NSLayoutConstraint.activate([
            // bottom bar
            self.currentTimeView.leadingAnchor.constraint(equalTo: parentMargins.leadingAnchor, constant: padding),
            self.currentTimeView.bottomAnchor.constraint(equalTo: parentMargins.bottomAnchor),
            self.currentTimeView.heightAnchor.constraint(equalToConstant: 44),

            self.bufferProgressView.leadingAnchor.constraint(equalTo: self.currentTimeView.trailingAnchor, constant: padding),
            self.bufferProgressView.centerYAnchor.constraint(equalTo: self.currentTimeView.centerYAnchor),
            self.bufferProgressView.heightAnchor.constraint(equalToConstant: 2),

            self.timeSlider.leadingAnchor.constraint(equalTo: self.bufferProgressView.leadingAnchor),
            self.timeSlider.trailingAnchor.constraint(equalTo: self.bufferProgressView.trailingAnchor),
            self.timeSlider.centerYAnchor.constraint(equalTo: self.bufferProgressView.centerYAnchor),

            self.totalTimeView.leadingAnchor.constraint(equalTo: self.bufferProgressView.trailingAnchor, constant: padding),
            self.totalTimeView.bottomAnchor.constraint(equalTo: parentMargins.bottomAnchor),
            self.totalTimeView.heightAnchor.constraint(equalToConstant: 44),
            self.totalTimeView.trailingAnchor.constraint(lessThanOrEqualTo: parentMargins.trailingAnchor, constant: -padding),

            self.bottomBarRightStackView.leadingAnchor.constraint(equalTo: self.totalTimeView.trailingAnchor),
            self.bottomBarRightStackView.trailingAnchor.constraint(equalTo: parentMargins.trailingAnchor),
            self.bottomBarRightStackView.bottomAnchor.constraint(equalTo: parentMargins.bottomAnchor),
            self.bottomBarRightStackView.heightAnchor.constraint(equalToConstant: 44),

            self.fullScreenButton.widthAnchor.constraint(equalToConstant: 44),

            // top bar
            self.topBarLeftStackView.leadingAnchor.constraint(equalTo: parentMargins.leadingAnchor),
            self.topBarLeftStackView.topAnchor.constraint(equalTo: parentMargins.topAnchor),
            self.topBarLeftStackView.heightAnchor.constraint(equalToConstant: 44),

            self.emptyView.widthAnchor.constraint(equalToConstant: 0),
            self.closeButton.widthAnchor.constraint(equalToConstant: 44),
            self.offlineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: parentMargins.leadingAnchor, constant: padding),

            self.titleView.leadingAnchor.constraint(equalTo: self.topBarLeftStackView.trailingAnchor, constant: padding),
            self.titleView.topAnchor.constraint(equalTo: parentMargins.topAnchor),
            self.titleView.heightAnchor.constraint(equalToConstant: 44),

            self.topBarRightStackView.leadingAnchor.constraint(equalTo: self.titleView.trailingAnchor, constant: padding),
            self.topBarRightStackView.topAnchor.constraint(equalTo: parentMargins.topAnchor),
            self.topBarRightStackView.trailingAnchor.constraint(equalTo: parentMargins.trailingAnchor),

            self.pictureInPictureButton.widthAnchor.constraint(equalToConstant: 44),
            self.settingsButton.widthAnchor.constraint(equalToConstant: 44),

            // center
            self.playPauseButton.centerXAnchor.constraint(equalTo: parentMargins.centerXAnchor),
            self.playPauseButton.centerYAnchor.constraint(equalTo: parentMargins.centerYAnchor),
            self.playPauseButton.heightAnchor.constraint(equalToConstant: 66),
            self.playPauseButton.widthAnchor.constraint(equalToConstant: 66),

            NSLayoutConstraint(item: self.seekForwardButton, attribute: .centerX, relatedBy: .equal, toItem: parentMargins, attribute: .centerX, multiplier: 1.5, constant: 0),
            self.seekForwardButton.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor),
            self.seekForwardButton.heightAnchor.constraint(equalToConstant: 44),
            self.seekForwardButton.widthAnchor.constraint(equalToConstant: 44),

            NSLayoutConstraint(item: self.seekBackwardButton, attribute: .centerX, relatedBy: .equal, toItem: parentMargins, attribute: .centerX, multiplier: 0.5, constant: 0),
            self.seekBackwardButton.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor),
            self.seekBackwardButton.heightAnchor.constraint(equalToConstant: 44),
            self.seekBackwardButton.widthAnchor.constraint(equalToConstant: 44),
        ])

        if #available(iOS 11, *) {
            self.airPlayButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        }

    }

    private func formatTime(_ time: TimeInterval) -> String {
        if time.isNaN || time.isInfinite {
            return "0:00"
        }

        let seconds = Int(time) % 60
        let minutes = Int(time / 60)
        let hours = Int(time / 60 / 60)

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    @objc private func togglePictureInPictureMode() {
        print("Tap on pip button")
        self.delegate.togglePictureInPictureMode()
    }

    @objc private func showMediaSelection() {
        self.delegate.showMediaSelection(for: self.settingsButton)
    }

    @objc private func playPauseVideo() {
        if self.playPauseButton.isSelected {
            self.delegate.pausePlayback()
        } else {
            self.delegate.startPlayback()
        }
    }

    @objc private func seekForwards() {
        self.delegate.seekForwards()
    }

    @objc private func seekBackwards() {
        self.delegate.seekBackwards()
    }

    @objc private func changeProgress(sender: UISlider) {
        self.delegate.seekTo(progress: Double(sender.value))
    }

    @objc private func toggleFullScreenMode() {
        self.delegate.toggleFullScreenMode()
    }

    @objc private func dismissPlayer() {
        self.delegate.dismissPlayer()
    }

    func setTitle(_ title: String?) {
        self.titleView.text = title
    }

    func adaptToItem(_ item: AVPlayerItem) {
        let duration = item.duration
        let isValidDuration = duration.isNumeric && duration.value != 0
        let seconds = isValidDuration ? CMTimeGetSeconds(duration): 0.0
        let currentTime = CMTimeGetSeconds(item.currentTime())

        self.timeSlider.value = isValidDuration ? Float(currentTime / seconds) : 0.0

        self.playPauseButton.isEnabled = isValidDuration
        self.timeSlider.isEnabled = isValidDuration

        self.totalTimeView.text = self.formatTime(seconds)
        self.offlineLabel.isHidden = !item.asset.isLocalAsset
    }

    func adaptToTimeControlStatus(_ timeControlStatus: AVPlayer.TimeControlStatus) {
        self.playPauseButton.isSelected = timeControlStatus == .playing
        self.playPauseButton.isHidden = timeControlStatus == .waitingToPlayAtSpecifiedRate
    }

    func adaptToTimeChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        self.currentTimeView.text = self.formatTime(currentTime)
        if !self.timeSlider.isHighlighted {
            self.timeSlider.value = Float(currentTime / totalTime)
        }
    }

    func adaptToBufferChange(availableTime: TimeInterval, totalTime: TimeInterval) {
        self.bufferProgressView.progress = Float(availableTime / totalTime)
    }

    func adaptToLayoutState(_ state: LayoutState, allowFullScreenMode: Bool, isStandAlone: Bool) {
        let hideFullScreenButton = state == .remote || !allowFullScreenMode || isStandAlone
        self.fullScreenButton.isHidden = hideFullScreenButton
        self.fullScreenButton.isSelected = state == .fullscreen
        self.closeButton.isHidden = !isStandAlone
        self.titleView.isHidden = state != .fullscreen
    }

    func adaptToPictureInPicturePossible(_ pictureInPicturePossible: Bool) {
        self.pictureInPictureButton.isEnabled = pictureInPicturePossible
    }

    @available(iOS 11, *)
    func adaptToMultiRouteOutput(for multipleRoutesDetected: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.airPlayButton.isHidden = !multipleRoutesDetected
            }
        }
    }

}

extension AVAsset {
    var isLocalAsset: Bool {
        guard let urlAsset = self as? AVURLAsset else { return false }
        return urlAsset.url.isFileURL
    }
}


extension UIImage {

    static func bingeImage(named name: String) -> UIImage? {
        let bundle = Bundle(for: BingeControlsViewController.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }

}
