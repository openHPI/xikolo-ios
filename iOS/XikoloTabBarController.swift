//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class XikoloTabBarController: UITabBarController {

    struct Configuration {
        let backgroundColor: UIColor
        let textColor: UIColor
        let message: String?
    }

    private static let messageViewHeight: CGFloat = 16
    private static let messageLabelFontSize: CGFloat = 12

    private static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()

    private var messageView = UIView()
    private var messageLabel = UILabel()

    private var _status: APIStatus = .standard
    var status: APIStatus {
        get {
            return self._status
        }
        set {
            guard self.status != newValue else { return }

            // allow only some status changes
            switch (self.status, newValue) {
            case (.standard, _):
                break
            case (.deprecated, .maintenance):
                break
            case (.deprecated, .expired):
                break
            case (.maintenance, .standard):
                break
            case (.maintenance, .expired):
                break
            default:
                return
            }

            log.info("Update app state from %@ to %@", String(describing: self.status), String(describing: newValue))
            let animationDuration: TimeInterval = self.status == .standard ? 0 : 0.25
            UIView.animate(withDuration: animationDuration) {
                self._status = newValue
                self.updateMessageViewAppearance()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustViewForKeyboardShow(_:)),
                                               name: APIStatus.didChangeNotification,
                                               object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: XikoloTabBarController.messageViewHeight)
        self.messageLabel.textAlignment = .center
        self.messageLabel.font = UIFont.systemFont(ofSize: XikoloTabBarController.messageLabelFontSize)
        self.messageView.addSubview(self.messageLabel)
        self.messageLabel.autoresizingMask = [.flexibleWidth]

        self.messageView.frame = CGRect(x: 0, y: self.tabBar.frame.height, width: self.view.frame.width, height: 0)
        self.tabBar.addSubview(self.messageView)
        self.messageView.autoresizingMask = [.flexibleWidth]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make sure we can correctly determine the height of tab bar items
        self.tabBar.layoutSubviews()

        self.updateMessageViewAppearance()
    }

    @objc private func adjustViewForKeyboardShow(_ notification: Notification) {
        guard let status = notification.userInfo?[APIStatusNotificationKey.status] as? APIStatus else { return }
        self.status = status
    }

    private func updateMessageViewAppearance() {
        let config = self.configuration(for: self.status)
        self.messageView.backgroundColor = config.backgroundColor
        self.messageLabel.textColor = config.textColor
        self.messageLabel.text = config.message

        let tabBarHeight = self.tabBar.frame.height
        let tabBarItemHeight = self.heightOfTabBarItems() ?? tabBarHeight
        let tabBarOffset = self.status == .standard ? 0 : XikoloTabBarController.messageViewHeight

        var newTabBarFrame = self.tabBar.frame
        newTabBarFrame.origin.y = self.view.frame.height - tabBarHeight - tabBarOffset

        var newMessageViewFrame = self.messageView.frame
        newMessageViewFrame.origin.y = self.status == .standard ? tabBarHeight : tabBarItemHeight
        newMessageViewFrame.size.height = self.status == .standard ? 0 : tabBarHeight - tabBarItemHeight + tabBarOffset

        self.messageView.frame = newMessageViewFrame
        self.tabBar.frame = newTabBarFrame

        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarOffset, right: 0)
        }
    }

    private func configuration(for status: APIStatus) -> Configuration {
        switch status {
        case .standard:
            return Configuration(backgroundColor: .white, textColor: .clear, message: nil)
        case .maintenance:
            let format = NSLocalizedString("app-state.maintenance.server maintenance on %@",
                                           comment: "App state message for server maintenance")
            let message = String.localizedStringWithFormat(format, UIApplication.appName)
            return Configuration(backgroundColor: Brand.default.colors.window, textColor: .white, message: message)
        case .deprecated(expiresOn: let expirationDate):
            let formattedExpirationDate = XikoloTabBarController.dateFormatter.string(from: expirationDate)
            let format = NSLocalizedString("app-state.api-deprecated.please update the %@ app before %@",
                                           comment: "App state message for deprecated API version")
            let message = String.localizedStringWithFormat(format, UIApplication.appName, formattedExpirationDate)
            return Configuration(backgroundColor: .orange, textColor: .white, message: message)
        case .expired:
            let format = NSLocalizedString("app-state.api-expired.app version of %@ expired - please update",
                                           comment: "App state message for expired API version")
            let message = String.localizedStringWithFormat(format, UIApplication.appName)
            return Configuration(backgroundColor: .red, textColor: .white, message: message)
        }
    }

    private func heightOfTabBarItems() -> CGFloat? {
        var heightCounter: [CGFloat: Int] = [:]
        for subview in self.tabBar.subviews.filter({ $0 != self.messageView }) {
            let subviewHeight = subview.frame.height
            if let count = heightCounter[subviewHeight] {
                heightCounter[subviewHeight] = count + 1
            } else {
                heightCounter[subviewHeight] = 1
            }
        }

        let itemsCounts = self.tabBar.items?.count ?? 0
        return heightCounter.first { $1 == itemsCounts }?.key
    }

}
