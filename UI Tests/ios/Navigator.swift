//
//  Navigator.swift
//  xikolo-ios
//
//  Created by Max Bothe on 30.01.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import XCTest

struct Navigator {

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
