//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class LoadingButton: DynamicSizeButton {

    private lazy var spinner: CircularProgressView = {
        let progress = CircularProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.lineWidth = 2.2
        progress.tintColor = self.tintColor

        let progressValue: CGFloat? = nil
        progress.updateProgress(progressValue)

        progress.alpha = 0.0
        return progress
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(self.spinner)
        self.addConstraints([
            self.spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.spinner.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5),
            self.spinner.widthAnchor.constraint(equalTo: self.spinner.heightAnchor),
        ])
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.spinner.tintColor = self.tintColor
    }

    func startAnimation() {
        UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.titleLabel?.layer.opacity = 0.0
        } completion: { [weak self] _ in
            self?.titleLabel?.isHidden = true
            UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: .curveEaseOut) { [weak self] in
                self?.spinner.alpha = 1.0
            }
        }
    }

    func stopAnimation() {
        self.titleLabel?.layer.opacity = 0.0
        self.titleLabel?.isHidden = false
        UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.spinner.alpha = 0.0
        } completion: { _ in
            UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: .curveEaseOut) { [weak self] in
                self?.titleLabel?.layer.opacity = 1.0
            }
        }
    }

}
