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
        app.launchArguments = ["-cleanStatusBar"]
        setupSnapshot(app)
        app.launch()
    }

    func testMakeScreenshots() {
        let app = XCUIApplication()

        LoginHelper.logoutIfPossible()

        // Course list
        Navigator.goToTabBarItem(.courses)
        sleep(5)
        snapshot("1-CourseList")

        LoginHelper.loginIfPossible()

        // Dashboard
        Navigator.goToTabBarItem(.dashboard)
        app.tables.cells["CourseOverview"].waitForExistence(timeout: 5)

        // Course item list
        // tap on first element in current courses view
        // course cell must be accessibility element (.isAccessibilityElement = true)
        let currentCoursesOverview = app.tables.cells["CourseOverview"].firstMatch
        let firstCurrentCourse = currentCoursesOverview.otherElements["CourseCell"].firstMatch
        firstCurrentCourse.tap()
        sleep(5)
        snapshot("3-Course-Items")

        // tap on first video item
        app.tables.cells["CourseItemCell-video"].firstMatch.tap()
        sleep(4)
        snapshot("4-Video-Item")
    }

}
