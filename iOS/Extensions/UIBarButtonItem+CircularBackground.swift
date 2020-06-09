//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CircularButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2
        self.clipsToBounds = true
    }

}

extension UIBarButtonItem {

    static func circularItem(
        with image: UIImage?,
        backgroundColor: UIColor? = ColorCompatibility.secondarySystemBackground.withAlphaComponent(0.9),
        target: Any?,
        action: Selector
    ) -> UIBarButtonItem {
        let button = CircularButton(type: .custom)
        button.setImage(image, for: .normal)
        button.backgroundColor = backgroundColor
        button.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }

}
