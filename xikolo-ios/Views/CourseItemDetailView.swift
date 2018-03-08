//
//  CourseItemDetailView.swift
//  xikolo-ios
//
//  Created by Max Bothe on 07.03.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import UIKit

class CourseItemDetailView : UIView {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 2.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let shimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    var isShimmering: Bool = false {
        didSet {
            guard self.isShimmering != oldValue else { return }

            self.stackView.isHidden = self.isShimmering
            self.shimmerView.isHidden = !self.isShimmering

            let animationKey = "shimmer"
            if self.isShimmering, self.shimmerView.layer.animation(forKey: animationKey) == nil {
                self.shimmerView.layer.add(self.pulseAnimation, forKey: animationKey)
            } else {
                self.shimmerView.layer.removeAnimation(forKey: animationKey)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(self.stackView)
        self.addSubview(self.shimmerView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.stackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.stackView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.shimmerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 3),
            NSLayoutConstraint(item: self.shimmerView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 3),
            NSLayoutConstraint(item: self.shimmerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.shimmerView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0),
        ])
    }

    func setContent(_ content: [DetailedData], inOfflineMode isOffline: Bool) {
        self.stackView.arrangedSubviews.forEach { view in
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for (index, contentItem) in content.enumerated() {
            let label = self.label(forContentItem: contentItem, inOfflineMode: isOffline)
            self.stackView.addArrangedSubview(label)

            if contentItem.isOfflineAvailable, contentItem.showOfflineIcon, let image = UIImage(named: "downloaded") {
                let imageView = UIImageView(image: image)
                imageView.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = contentItem.isOfflineAvailable ? UIColor.darkText.withAlphaComponent(0.7) : UIColor.lightGray.withAlphaComponent(0.7)
                self.stackView.addArrangedSubview(imageView)
            }

            if index < content.count - 1 {
                let separator = self.separator(inOfflineMode: isOffline)
                self.stackView.addArrangedSubview(separator)
            }
        }

        self.isShimmering = false
    }

    private func label(forContentItem contentItem: DetailedData, inOfflineMode isOffline: Bool) -> UILabel {
        let color: UIColor = contentItem.isOfflineAvailable || !isOffline ? .darkText : .lightGray
        return self.label(withText: contentItem.text, color: color)
    }

    private func separator(inOfflineMode isOffline: Bool) -> UILabel {
        let color: UIColor = !isOffline ? .darkText : .lightGray
        return self.label(withText: " · ", color: color)
    }

    private func label(withText text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = text
        label.textColor = color
        label.sizeToFit()
        return label
    }

    private var pulseAnimation : CAAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
        pulseAnimation.fromValue = UIColor(white: 0.9, alpha: 1.0).cgColor
        pulseAnimation.toValue = UIColor(white: 0.95, alpha: 1.0).cgColor
        pulseAnimation.duration = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        return pulseAnimation
    }

}
