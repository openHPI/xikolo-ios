//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

struct Routes {

    struct Header {
        static let userPlatformKey = "User-Platform"
        static let userPlatformValue = "iOS"

        static let acceptKey = "Accept"
        static let acceptValue = "application/vnd.api+json; xikolo-version=\(Routes.apiVersion)"
        static let acceptPDF = "application/pdf"

        static let authKey = "Authorization"
        static let authValuePrefix = "Token token="
        static let apiVersionExpirationDate = "X-Api-Version-Expiration-Date"
    }

    struct HeaderParameter {
        static let email = "email"
        static let password = "password"
    }

    struct QueryItem {
        static let inApp = URLQueryItem(name: "in_app", value: "true")
        static let redirect = URLQueryItem(name: "redirect_to", value: "/auth/" + Brand.default.platformTitle)
    }

    static let base = URL(string: "https://" + Brand.default.host).require(hint: "Invalid base URL")

    static let api = Routes.base.appendingPathComponents(["api", "v2"])
    private static let apiVersion = "3"

    static let authenticate = Routes.api.appendingPathComponent("authenticate")
    static let register = Routes.base.appendingPathComponents(["account", "new"]).appendingInAppParameter()
    static let singleSignOn = Routes.base.appendingQueryItems([Routes.QueryItem.inApp, Routes.QueryItem.redirect])

    static let courses = Routes.base.appendingPathComponent("courses")

    static var imprint = Brand.default.imprintURL.appendingInAppParameter()
    static let privacy = Brand.default.privacyURL.appendingInAppParameter()
    static let github = URL(string: "https://github.com/openHPI/xikolo-ios").require(hint: "Invalid GitHub URL")

    static var localizedForgotPasswordURL: URL {
        let url = Routes.base.appendingPathComponents(["account", "reset", "new"])
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

        var queryItems = [Routes.QueryItem.inApp]
        if let locale = NSLocale.preferredLanguages.first {
            queryItems.append(URLQueryItem(name: "locale", value: locale))
        }

        urlComponents?.queryItems = queryItems

        let localizedURL = urlComponents?.url
        return localizedURL.require(hint: "Invalid URL for password reset")
    }

}

private extension URL {

    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }

    func appendingInAppParameter() -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [Routes.QueryItem.inApp]
        let url = urlComponents?.url
        return url.require(hint: "Invalid url with in-app parameter")
    }

}
