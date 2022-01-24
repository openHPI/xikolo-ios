//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CustomWidthNavigationController: UINavigationController {

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
            self.navigationBar.barTintColor = ColorCompatibility.systemBackground
            self.navigationBar.shadowImage = UIImage()
            self.hideShadowImage(inView: self.view)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCustomLayoutMargins()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        self.updateCustomLayoutMargins()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 13, *) {} else {
            self.hideShadowImage(inView: self.view)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateCustomLayoutMargins()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            self.updateCustomLayoutMargins()
        }
    }

    private func updateCustomLayoutMargins() {
        let customInsets = NSDirectionalEdgeInsets.customInsets(for: self)
        self.view.directionalLayoutMargins = customInsets
        self.navigationBar.preservesSuperviewLayoutMargins = true

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationBar.directionalLayoutMargins.leading = customInsets.leading
            self.navigationBar.directionalLayoutMargins.trailing = customInsets.trailing
        }

        self.navigationBar.layoutMarginsDidChange()
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
