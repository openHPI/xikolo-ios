//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseNavigationController: XikoloNavigationController {

    enum BarTintStyle {
        case light
        case dark

        var color: UIColor {
            switch self {
            case .light:
                return .white
            case .dark:
                return .black
            }
        }
    }

    private var pendingGestureRecognizer: UIGestureRecognizer?
    private var lastNavigationBarProgress: CGFloat?
    private var barTintStyle: BarTintStyle = .light {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            if let lastNavigationBarProgress = self.lastNavigationBarProgress {
                self.updateNavigationBar(forProgress: lastNavigationBarProgress)
            }
        }
    }

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        let headerHidden = self.traitCollection.verticalSizeClass == .compact
        if (self.lastNavigationBarProgress ?? 0.0) >= 1.0 || headerHidden || self.viewControllers.count > 1 {
            return .default
        } else {
            switch self.barTintStyle {
            case .light:
                return .lightContent
            case .dark:
                if #available(iOS 13, *) {
                    return .darkContent
                } else {
                    return .default
                }
            }
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override var childForStatusBarHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        let pageViewController = self.topViewController as? UIPageViewController
        return pageViewController?.viewControllers?.first
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let lastNavigationBarProgress = self.lastNavigationBarProgress {
                    self.updateNavigationBar(forProgress: lastNavigationBarProgress)
                }
            }
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard self.presentedViewController != nil else { return }
        super.dismiss(animated: flag, completion: completion)
    }

    func adjustToUnderlyingColor(_ color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        // Refers to this suggeted formula: https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        let brightnessValue = (red * 299 + green * 587 + blue * 114) / 1000 * 255
        let isBright = brightnessValue > 125

        self.barTintStyle = isBright ? .dark : .light
    }

    func updateNavigationBar(forProgress progress: CGFloat) {
        self.lastNavigationBarProgress = progress

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

        let tintColor: UIColor
        switch self.barTintStyle {
        case .light:
            tintColor = UIColor(hue: hue, saturation: saturation * mappedProgress, brightness: (1 - mappedProgress * (1 - brightness)), alpha: alpha)
        case .dark:
            tintColor = UIColor(hue: hue, saturation: saturation * mappedProgress, brightness: mappedProgress * brightness, alpha: alpha)
        }

        self.navigationBar.tintColor = tintColor

        var transparentBackground: UIImage

        var backgroundRed: CGFloat = 0
        var backgroundGreen: CGFloat = 0
        var backgroundBlue: CGFloat = 0
        var backgroundAlpha: CGFloat = 1

        ColorCompatibility.systemBackground.getRed(&backgroundRed, green: &backgroundGreen, blue: &backgroundBlue, alpha: &backgroundAlpha)

        // The background of a navigation bar switches from being translucent to transparent when a background image is applied.
        // Below, a background image is dynamically generated with the desired opacity.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               self.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: backgroundRed, green: backgroundGreen, blue: backgroundBlue, alpha: backgroundAlpha * navigationBarAlpha)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationBar.setBackgroundImage(transparentBackground, for: .default)
        self.navigationBar.setBackgroundImage(transparentBackground, for: .compact)

        self.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ColorCompatibility.label.withAlphaComponent(mappedProgress),
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
