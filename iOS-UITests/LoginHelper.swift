//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

class LoginHelper { // swiftlint:disable:this convenience_type

    static var loginCredentials: (email: String, password: String) {
        let bundle = Bundle(for: LoginHelper.self)
        let brandName = bundle.object(forInfoDictionaryKey: "BRAND_NAME") as? String
        let brandCredentialsPath = brandName.flatMap { bundle.path(forResource: "Credentials-\($0)", ofType: "plist") }
        let defaultCredentialsPath = bundle.path(forResource: "Credentials", ofType: "plist")

        guard let path = brandCredentialsPath ?? defaultCredentialsPath else {
            XCTFail("Credentials.plist not found")
            return (email: "", password: "")
        }

        guard let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
            XCTFail("Credentials.plist has wrong structure")
            return (email: "", password: "")
        }

        guard let email = dict["test-login-email"], let password = dict["test-login-password"] else {
            XCTFail("Credentials.plist has missing values")
            return (email: "", password: "")
        }

        return (email: email, password: password)
    }

    static func loginIfPossible() {
        let app = XCUIApplication()
        Navigator.goToTabBarItem(.account)
        let loginButton = app.navigationBars.buttons.element(boundBy: 0)

        guard loginButton.exists else { return }

        loginButton.tap()

        let credentials = self.loginCredentials

        let emailTextField = app.textFields.element(boundBy: 0)
        emailTextField.tap()
        emailTextField.typeText(credentials.email)

        let passwortSecureTextField = app.secureTextFields.element(boundBy: 0)
        passwortSecureTextField.tap()
        passwortSecureTextField.typeText(credentials.password)

        app.buttons["loginButton"].tap()
    }

    static func logoutIfPossible() {
        let app = XCUIApplication()
        Navigator.goToTabBarItem(.account)
        let logoutCell = app.tables.cells["logoutCell"]
        if logoutCell.exists {
            logoutCell.tap()
        }
    }

}
