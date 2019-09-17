//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

class ScreenshotsDark: XCTestCase {

    override func setUp() {
        super.setUp()

        self.continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-cleanStatusBar", "-forceDarkMode"]
        setupSnapshot(app)
        app.launch()
    }

    func testMakeScreenshots() {
        let app = XCUIApplication()

        LoginHelper.loginIfPossible()

        // Dashboard
        Navigator.goToTabBarItem(.dashboard)
        sleep(5)
        snapshot("2-Dashboard")
    }

}