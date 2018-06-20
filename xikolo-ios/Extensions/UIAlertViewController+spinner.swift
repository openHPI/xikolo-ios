//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIAlertController {

    convenience init(spinnerTitled title: String?, preferredStyle: UIAlertControllerStyle) {
        let progress = CircularProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.lineWidth = 2

        let progressValue: CGFloat? = nil
        progress.updateProgress(progressValue)

        progress.addConstraint(NSLayoutConstraint(item: progress,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 25))

        self.init(title: title, customView: progress, fallbackMessage: nil, preferredStyle: preferredStyle)
    }

}
