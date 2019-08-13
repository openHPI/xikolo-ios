//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseNavigationController: XikoloNavigationController {

    private var pendingGestureRecognizer: UIGestureRecognizer?

    var courseViewController: CourseViewController? {
        return self.viewControllers.first as? CourseViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.setBackgroundImage(UIImage(), for: .compact)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = .white

        if let gestureRecognizer = self.pendingGestureRecognizer {
            self.view.addGestureRecognizer(gestureRecognizer)
        }
    }

    override var childForStatusBarHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let pageViewController = self.topViewController as? UIPageViewController else {
            return
        }

        guard pageViewController.viewControllers?.first is VideoViewController else {
            return
        }

        for view in self.view.subviews {
            view.layer.masksToBounds = !self.navigationBar.isHidden
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard self.presentedViewController != nil else { return }
        super.dismiss(animated: flag, completion: completion)
    }

    func updateNavigationBar(forProgress progress: CGFloat) {
        let headerHidden = self.traitCollection.verticalSizeClass == .compact
        var mappedProgress = headerHidden ? 1.0 : progress
        mappedProgress = max(0, min(mappedProgress, 1)) // clamping
        mappedProgress = pow(mappedProgress, 3) // ease in
        mappedProgress = min(mappedProgress, 0.995) // otherwise the bar switches to translucent

        let navigationBarAlpha = mappedProgress

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1
        Brand.default.colors.window.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let tintColor = UIColor(hue: hue, saturation: saturation * mappedProgress, brightness: (1 - mappedProgress * (1 - brightness)), alpha: alpha)
        self.navigationBar.tintColor = tintColor

        var transparentBackground: UIImage

        // The background of a navigation bar switches from being translucent to transparent when a background image is applied.
        // Below, a background image is dynamically generated with the desired opacity.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               self.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: navigationBarAlpha)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationBar.setBackgroundImage(transparentBackground, for: .default)
        self.navigationBar.setBackgroundImage(transparentBackground, for: .compact)

        let textColor = UIColor(white: 0.1, alpha: mappedProgress)
        self.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: textColor,
        ]
    }

    func addDismissalGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let view = self.viewIfLoaded {
            view.addGestureRecognizer(gestureRecognizer)
        } else {
            self.pendingGestureRecognizer = gestureRecognizer
        }
    }

    @objc func closeCourse() {
        super.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

}
