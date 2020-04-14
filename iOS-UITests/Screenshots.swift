//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

class Screenshots: XCTestCase {

    override func setUp() {
        super.setUp()

        self.continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testMakeScreenshots() {
        let app = XCUIApplication()

        LoginHelper.logoutIfPossible()

        // Course list
        Navigator.goToTabBarItem(.courses)
        sleep(15)
        snapshot("1-CourseList")

        LoginHelper.loginIfPossible()

        // Dashboard
        Navigator.goToTabBarItem(.dashboard)
        sleep(15)

        // Course item list
        // tap on first element in current courses view
        // course cell must be accessibility element (.isAccessibilityElement = true)
        let currentCoursesOverview = app.collectionViews.firstMatch
        let firstCurrentCourse = currentCoursesOverview.cells.firstMatch.firstMatch
        firstCurrentCourse.tap()
        sleep(15)
        snapshot("3-Course-Items")

        // tap on first video item
        app.tables.cells["CourseItemCell-video"].firstMatch.tap()
        sleep(10)
        snapshot("4-Video-Item")
    }

}
