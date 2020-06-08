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

    convenience init(image: UIImage?, circularBackgroundColor: UIColor?, target: Any?, action: Selector) {
        let button = CircularButton(type: .custom)
        button.setImage(image, for: .normal)
        button.backgroundColor = circularBackgroundColor
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }

}
