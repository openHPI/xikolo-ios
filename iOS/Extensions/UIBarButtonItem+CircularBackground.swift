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

        if let primaryAction = primaryAction {
            if #available(iOS 14, *) {
                let action = UIAction(action: primaryAction)
                button.addAction(action, for: .touchUpInside)
            } else {
                let actionWrapper = UIBarButtonItem.ActionWrapper(action: primaryAction.handler)
                button.addTarget(actionWrapper, action: #selector(actionWrapper.performAction), for: .touchUpInside)
            }
        }

        if let menuActions = menuActions {
            if #available(iOS 14, *) {
                button.menu = UIMenu(title: "", children: menuActions.asActions())
                button.showsMenuAsPrimaryAction = primaryAction == nil
            } else {
                let showAlertController = { [weak item, weak target] in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    alert.popoverPresentationController?.barButtonItem = item

                    for action in menuActions.asAlertActions() {
                        alert.addAction(action)
                    }

                    alert.addCancelAction()

                    target?.present(alert, animated: trueUnlessReduceMotionEnabled)
                }

                let actionWrapper = UIBarButtonItem.ActionWrapper(action: showAlertController)

                if primaryAction == nil {
                    button.addTarget(actionWrapper, action: #selector(actionWrapper.performAction), for: .touchUpInside)
                } else {
                    let longPress = UILongPressGestureRecognizer(target: actionWrapper, action: #selector(actionWrapper.performAction))
                    button.addGestureRecognizer(longPress)
                }
            }
        }

        item.customView = button

        return item

    }

}
