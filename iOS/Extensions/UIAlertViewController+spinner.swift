//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIAlertController {

    convenience init(spinnerTitled title: String?, preferredStyle: UIAlertController.Style) {
        let progress = CircularProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.lineWidth = 2

        let progressValue: CGFloat? = nil
        progress.updateProgress(progressValue)

        progress.heightAnchor.constraint(equalToConstant: 25).isActive = true

        self.init(title: title, customView: progress, fallbackMessage: nil, preferredStyle: preferredStyle)
    }

}
