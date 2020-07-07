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
        target: UIViewController, // for iOS 13 and prior
        primaryAction: Action? = nil,
        menuActions: [Action]? = nil
    ) -> UIBarButtonItem {
        let item = UIBarButtonItem()

        let button = CircularButton(type: .custom)
        button.setImage(image, for: .normal)
        button.backgroundColor = backgroundColor
        button.add(primaryAction: primaryAction, menuActions: menuActions, on: target, barButtonItem: item)

        item.customView = button

        return item
    }

}

extension UIButton {

    private final class ActionWrapper: NSObject {

        private let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
            super.init()
        }

        @objc func performAction() {
            self.action()
        }

    }

    func add(
        primaryAction: Action? = nil,
        menuActions: [Action]? = nil,
        menuTitle: String? = nil,
        menuMessage: String? = nil,
        on target: UIViewController?,
        barButtonItem: UIBarButtonItem? = nil
    ) {
        if let primaryAction = primaryAction {
            if #available(iOS 14, *) {
                let action = UIAction(action: primaryAction)
                self.addAction(action, for: .touchUpInside)
            } else {
                let actionWrapper = UIButton.ActionWrapper(action: primaryAction.handler)
                self.addTarget(actionWrapper, action: #selector(actionWrapper.performAction), for: .touchUpInside)
            }
        }

        if let menuActions = menuActions {
            if #available(iOS 14, *) {
                self.menu = UIMenu(title: "", children: menuActions.asActions())
                self.showsMenuAsPrimaryAction = primaryAction == nil
            } else {
                let showAlertController = { [weak self, weak target, weak barButtonItem] in
                    let alert = UIAlertController(title: menuTitle, message: menuMessage, preferredStyle: .actionSheet)

                    if let item = barButtonItem {
                        alert.popoverPresentationController?.barButtonItem = item
                    } else {
                        alert.popoverPresentationController?.sourceView = self
                        alert.popoverPresentationController?.sourceRect = self?.bounds ?? .zero
                    }

                    for action in menuActions.asAlertActions() {
                        alert.addAction(action)
                    }

                    alert.addCancelAction()

                    target?.present(alert, animated: trueUnlessReduceMotionEnabled)
                }

                let actionWrapper = UIButton.ActionWrapper(action: showAlertController)

                if primaryAction == nil {
                    self.addTarget(actionWrapper, action: #selector(actionWrapper.performAction), for: .touchUpInside)
                } else {
                    let longPress = UILongPressGestureRecognizer(target: actionWrapper, action: #selector(actionWrapper.performAction))
                    self.addGestureRecognizer(longPress)
                }
            }
        }
    }

}
