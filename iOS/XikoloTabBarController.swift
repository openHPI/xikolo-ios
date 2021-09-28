//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class XikoloTabBarController: UITabBarController {

    enum Tabs: CaseIterable {
        case dashboard
        case channels
        case courses
        case news
        case more
        case account

        static var availableTabs: [Tabs] {
            return Self.allCases.filter(\.isAvailable)
        }

        var isAvailable: Bool {
            switch self {
            case .channels:
                return Brand.default.features.enableChannels
            case .news:
                return !self.additionalLearningResourcesAvailable
            case .more:
                return self.additionalLearningResourcesAvailable
            default:
                return true
            }
        }

        private var additionalLearningResourcesAvailable: Bool {
            return !Brand.default.additionalLearningMaterial.isEmpty
        }

        var index: Int {
            return Self.availableTabs.firstIndex(of: self).require()
        }

        var viewController: UIViewController? {
            switch self {
            case .dashboard:
                return R.storyboard.tabDashboard.instantiateInitialViewController()
            case .channels:
                return R.storyboard.tabChannels.instantiateInitialViewController()
            case .courses:
                return R.storyboard.tabCourses.instantiateInitialViewController()
            case .news:
                return R.storyboard.tabNews.instantiateInitialViewController()
            case .more:
                return R.storyboard.tabMore.instantiateInitialViewController()
            case .account:
                return R.storyboard.tabAccount.instantiateInitialViewController()
            }
        }

    }

    struct Configuration {
        let backgroundColor: UIColor
        let textColor: UIColor
        let message: String?
    }

    static func make() -> XikoloTabBarController {
        let tabBarController = XikoloTabBarController()
        tabBarController.viewControllers = Tabs.availableTabs.compactMap(\.viewController)
        return tabBarController
    }

    private static let messageViewHeight: CGFloat = 16
    private static let messageLabelFontSize: CGFloat = 12

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)

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

            logger.info("Update app state from %@ to %@", String(describing: self.status), String(describing: newValue))
            let animated = self.status != .standard
            UIView.animate(withDuration: defaultAnimationDuration(animated)) {
                self._status = newValue
                self.updateMessageViewAppearance()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.isTranslucent = false

        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }

        self.messageLabel.textAlignment = .center
        self.messageLabel.font = UIFont.systemFont(ofSize: XikoloTabBarController.messageLabelFontSize)
        self.messageView.addSubview(self.messageLabel)

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.messageLabel.topAnchor.constraint(equalTo: self.messageView.topAnchor),
            self.messageLabel.leadingAnchor.constraint(equalTo: self.messageView.leadingAnchor),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.messageView.trailingAnchor),
            self.messageLabel.heightAnchor.constraint(equalToConstant: XikoloTabBarController.messageViewHeight),
        ])

        self.messageView.frame = CGRect(x: 0, y: self.tabBar.frame.height, width: self.view.frame.width, height: 0)
        self.tabBar.addSubview(self.messageView)
        self.messageView.autoresizingMask = [.flexibleWidth]

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAPIStatusChange(_:)),
                                               name: APIStatus.didChangeNotification,
                                               object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Make sure we can correctly determine the height of tab bar items
        self.tabBar.layoutSubviews()

        self.updateMessageViewAppearance()
    }

    @objc private func handleAPIStatusChange(_ notification: Notification) {
        let newStatus = notification.userInfo?[APIStatusNotificationKey.status] as? APIStatus
        self.status = newStatus ?? .standard
    }

    private func updateMessageViewAppearance() {
        let config = self.configuration(for: self.status)
        self.messageView.backgroundColor = config.backgroundColor
        self.messageLabel.textColor = config.textColor
        self.messageLabel.text = config.message

        var newMessageViewFrame = self.messageView.frame
        newMessageViewFrame.origin.y = self.status == .standard ? 0 : -1 * XikoloTabBarController.messageViewHeight
        newMessageViewFrame.size.height = self.status == .standard ? 0 : XikoloTabBarController.messageViewHeight

        self.messageView.frame = newMessageViewFrame
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
