//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class XikoloNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.shadowImage = UIImage()

        if #available(iOS 11.0, *) {
            // Nothing to do here
        } else {
            self.hideShadowImage(inView: self.view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11, *) {} else {
            self.hideShadowImage(inView: self.view)
        }
    }

    @discardableResult private func hideShadowImage(inView view: UIView, level: Int = 0) -> Bool {
        if let imageView = view as? UIImageView {
            let size = imageView.bounds.size.height
            if size <= 1 && size > 0 && imageView.subviews.isEmpty {
                let forcedBackground = UIView(frame: imageView.bounds)
                forcedBackground.backgroundColor = .white
                imageView.addSubview(forcedBackground)
                forcedBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                return true
            }
        }

        for subview in view.subviews {
            if subview is UISearchBar || subview is UICollectionView || subview is UITableView || subview is UIRefreshControl || subview is UIVisualEffectView {
                continue
            }

            if self.hideShadowImage(inView: subview, level: level + 1) {
                break
            }
        }

        return false
    }

}
