//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class XikoloNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ColorCompatibility.systemBackground
            appearance.shadowColor = .clear
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        } else {
            self.navigationBar.backgroundColor = ColorCompatibility.systemBackground
            self.navigationBar.shadowImage = UIImage()
            self.hideShadowImage(inView: self.view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 13, *) {} else {
            self.hideShadowImage(inView: self.view)
        }
    }

    @discardableResult private func hideShadowImage(inView view: UIView, level: Int = 0) -> Bool {
        if let imageView = view as? UIImageView {
            let size = imageView.bounds.size.height
            if size <= 1 && size > 0 && imageView.subviews.isEmpty {
                let forcedBackground = UIView(frame: imageView.bounds)
                forcedBackground.backgroundColor = ColorCompatibility.systemBackground
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
