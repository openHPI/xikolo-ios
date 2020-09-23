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
        menuActions: [[Action]]? = nil
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

struct DeferredMenuActionConfiguration {

    let loadingMessage: String?
    let isLoadingRequired: () -> Bool
    let load: (_ completion: @escaping () -> Void) -> Void
    let actions: () -> [Action]

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

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func add(
        primaryAction: Action? = nil,
        menuActions: [[Action]]? = nil,
        deferredMenuActions: DeferredMenuActionConfiguration? = nil,
        menuTitle: String? = nil,
        menuMessage: String? = nil,
        on target: UIViewController?,
        barButtonItem: UIBarButtonItem? = nil
    ) {
        var actionWrappers: [UIButton.ActionWrapper] = []

        if let primaryAction = primaryAction {
            if #available(iOS 14, *) {
                let action = UIAction(action: primaryAction)
                self.addAction(action, for: .touchUpInside)
            } else {
                let actionWrapper = UIButton.ActionWrapper(action: primaryAction.handler)
                self.addTarget(actionWrapper, action: #selector(actionWrapper.performAction), for: .touchUpInside)
                actionWrappers.append(actionWrapper)
            }
        }

        if let menuActions = menuActions {
            if #available(iOS 14, *) {
                let submenus = menuActions.filter { !$0.isEmpty }.map { subMenuActions in
                    return UIMenu(title: "", options: .displayInline, children: subMenuActions.asActions())
                }

                self.menu = UIMenu(title: "", children: submenus)
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

                    for action in menuActions.flatMap({ $0 }).asAlertActions() {
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

                actionWrappers.append(actionWrapper)
            }
        } else if let deferredMenuActionsConfiguration = deferredMenuActions {
            if #available(iOS 14, *) {
                let actions: [UIMenuElement] = {
                    if deferredMenuActionsConfiguration.isLoadingRequired() {
                        let deferredItem = UIDeferredMenuElement { completion in
                            deferredMenuActionsConfiguration.load {
                                let actions = deferredMenuActionsConfiguration.actions().asActions()
                                completion(actions)
                            }
                        }

                        return [deferredItem]
                    } else {
                        return deferredMenuActionsConfiguration.actions().asActions()
                    }
                }()

                self.menu = UIMenu(title: "", children: actions)
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

                    for action in deferredMenuActionsConfiguration.actions().asAlertActions() {
                        alert.addAction(action)
                    }

                    alert.addCancelAction()

                    target?.present(alert, animated: trueUnlessReduceMotionEnabled)
                }

                let showSpinner = { [weak target] in
                    let alert = UIAlertController(spinnerTitled: deferredMenuActionsConfiguration.loadingMessage, preferredStyle: .alert)
                    alert.addCancelAction { _ in }

                    target?.present(alert, animated: trueUnlessReduceMotionEnabled)

                    deferredMenuActions?.load {
                        alert.dismiss(animated: trueUnlessReduceMotionEnabled)
                        showAlertController()
                    }
                }

                let action = {
                    if deferredMenuActionsConfiguration.isLoadingRequired() {
                        showSpinner()
                    } else {
                        showAlertController()
                    }
                }

                let actionWrapper = UIButton.ActionWrapper(action: action)

                if primaryAction == nil {
                    self.addTarget(actionWrapper, action: #selector(actionWrapper.performAction), for: .touchUpInside)
                } else {
                    let longPress = UILongPressGestureRecognizer(target: actionWrapper, action: #selector(actionWrapper.performAction))
                    self.addGestureRecognizer(longPress)
                }

                actionWrappers.append(actionWrapper)
            }
        }

        if #available(iOS 14, *) {} else {
            var associatedKey = "legacy_action_wrappers"
            objc_setAssociatedObject(self, &associatedKey, actionWrappers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func removeAllTargetsAndGestures() {
        if #available(iOS 14, *) {} else {
            self.removeTarget(nil, action: nil, for: .allEvents)
            self.gestureRecognizers?.forEach { self.removeGestureRecognizer($0) }
        }
    }

}
