//
//  XikoloTabBarController.swift
//  xikolo-ios
//
//  Created by Max Bothe on 11.01.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import UIKit

class XikoloTabBarController: UITabBarController {

    struct Configuration {
        let backgroundColor: UIColor
        let textColor: UIColor
        let message: String?
    }

    enum Status: Equatable {
        case standard
        case maintainance
        case deprecated(expiresOn: Date)
        case expired

        var values: [Status] {
            return [.standard, .maintainance, .deprecated(expiresOn: Date()), .expired]
        }

        private static let dateFormatter: DateFormatter = {
            var formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale.current
            return formatter
        }()

        static func ==(lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.standard, .standard): return true
            case (.maintainance, .maintainance): return true
            case let (.deprecated(l), .deprecated(r)): return l == r
            case (.expired, .expired): return true
            default: return false
            }
        }

        var configuration: Configuration {
            switch self {
            case .standard:
                return Configuration(backgroundColor: .white, textColor: .clear, message: nil)
            case .maintainance:
                let message = "Maintance"
                return Configuration(backgroundColor: Brand.windowTintColor, textColor: .white, message: message)
            case .deprecated(expiresOn: let expirationDate):
                let message = "Will deprecate on \(Status.dateFormatter.string(from: expirationDate))"
                return Configuration(backgroundColor: .orange, textColor: .white, message: message)
            case .expired:
                let message = "Expired"
                return Configuration(backgroundColor: .red, textColor: .white, message: message)
            }
        }

    }

    private static let messageViewHeight: CGFloat = 16
    private static let messageLabelFontSize: CGFloat = 12

    private var messageView = UIView()
    private var messageLabel = UILabel()

    private(set) var status: Status = .standard

    override func viewDidLoad() {
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

        let config = self.status.configuration
        self.messageView.backgroundColor = config.backgroundColor
        self.messageLabel.textColor = config.textColor
        self.messageLabel.text = config.message

        let tabBarHeight = self.tabBar.frame.height
        let tabBarItemHeight = self.tabBarItemHeight() ?? tabBarHeight
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

    func updateStatus(_ status: Status) {
        guard self.status != status else { return }

        let animationDuration: TimeInterval = self.status == .standard ? 0 : 0.25
        UIView.animate(withDuration: animationDuration) {
            self.status = status

            self.view.layoutSubviews()
            self.viewDidLayoutSubviews()
        }
    }

    private func tabBarItemHeight() -> CGFloat? {
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
        return heightCounter.filter { $1 == itemsCounts }.first?.key
    }

}
