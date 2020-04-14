//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

enum Navigator {

    enum TabBarItem {
        case dashboard
        case courses
        case account
    }

    static func goToTabBarItem(_ item: TabBarItem) {
        let tabBarItems = XCUIApplication().tabBars.buttons

        let index: Int = {
            let tabBarItemsCount = tabBarItems.count

            switch item {
            case .dashboard:
                return 0
            case .courses:
                return tabBarItemsCount - 3
            case .account:
                return tabBarItemsCount - 1
            }
        }()

        tabBarItems.element(boundBy: index).tap()
    }

}
