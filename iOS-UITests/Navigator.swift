//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

enum Navigator {

    enum TabBarItem: Int {
        case dashboard = 0
        case courses = 1
        case news = 2
        case settings = 3
    }

    static func goToTabBarItem(_ item: TabBarItem) {
        XCUIApplication().tabBars.buttons.element(boundBy: item.rawValue).tap()
    }

}
