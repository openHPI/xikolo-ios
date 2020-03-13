//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public enum Routes {

    public enum Header {
        public static let userPlatformKey = "X-User-Platform"
        public static let userPlatformValue = "iOS"

        public static let userAgentKey = "User-Agent"
        public static let userAgentValue = "\(UIApplication.appName)/\(UIApplication.appVersion) iOS/\(UIApplication.osVersion) (\(UIApplication.device))"

        public static let acceptKey = "Accept"
        public static let acceptLanguageKey = "Accept-Language"
        public static let acceptValue = "application/vnd.api+json; xikolo-version=\(Routes.apiVersion)"
        public static let acceptPDF = "application/pdf"

        public static let contentTypeKey = "Content-Type"
        public static let contentTypeValueJSONAPI = "application/vnd.api+json"

        public static let authKey = "Authorization"
        public static let authValuePrefix = "Token token="
        public static let apiVersionExpirationDate = "X-Api-Version-Expiration-Date"
    }

    public enum HeaderParameter {
        public static let email = "email"
        public static let password = "password"
    }

    enum QueryItem {
        static let inApp = URLQueryItem(name: "in_app", value: "true")
    }

    public static let base = URL(string: "https://" + Brand.default.host).require(hint: "Invalid base URL")

    static let api = Self.base.appendingPathComponents(["api", "v2"])
    private static let apiVersion = "3"

    static let authenticate = Self.api.appendingPathComponent("authenticate")
    public static let register = Self.base.appendingPathComponents(["account", "new"]).appendingInAppParameter()
    public static let singleSignOn: URL? = {
        guard let platformTitle = Brand.default.singleSignOn?.platformTitle else { return nil }
        return Self.base
            .appendingPathComponents(["auth", platformTitle])
            .appendingInAppParameter()
            .appendingQueryItem(URLQueryItem(name: "redirect_to", value: "/auth/" + platformTitle))
    }()

    public static let courses = Self.base.appendingPathComponent("courses")
    public static let dashboard = Self.base.appendingPathComponent("dashboard")
    public static let recap = Self.base.appendingPathComponent("learn")

    public static var imprint = Brand.default.imprintURL.appendingInAppParameter()
    public static let privacy = Brand.default.privacyURL.appendingInAppParameter()
    public static let github = URL(string: "https://github.com/openHPI/xikolo-ios").require(hint: "Invalid GitHub URL")

    public static var localizedForgotPasswordURL: URL {
        let url = Self.base.appendingPathComponents(["account", "reset", "new"])
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

        var queryItems = [Routes.QueryItem.inApp]
        if let locale = NSLocale.preferredLanguages.first {
            queryItems.append(URLQueryItem(name: "locale", value: locale))
        }

        urlComponents?.queryItems = queryItems

        let localizedURL = urlComponents?.url
        return localizedURL.require(hint: "Invalid URL for password reset")
    }

    public static func addCallbackParameters(to url: URL) -> URL {
        if Brand.default.singleSignOn?.provider == .oidc {
            return url.appendingInAppParameter()
        } else {
            return url
        }
    }

    public static func isAppAuthenticationURL(for request: URLRequest) -> URL? {
        guard let url = request.url, url.path == "/auth/app" else { return nil }
        return url
    }

    public static func isSingleSignOnCallbackURL(for request: URLRequest) -> URL? {
        guard let platformTitle = Brand.default.singleSignOn?.platformTitle else { return nil }
        guard let url = request.url, url.path == "/auth/\(platformTitle)/callback" else { return nil }
        return url
    }

}

private extension URL {

    func appendingQueryItem(_ queryItem: URLQueryItem) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false).require()
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = [queryItem]
        } else if !(urlComponents.queryItems?.contains(queryItem) ?? false) {
            urlComponents.queryItems?.append(queryItem)
        }

        return urlComponents.url.require(hint: "Invalid url with query item parameter")
    }

    func appendingInAppParameter() -> URL {
        return self.appendingQueryItem(Routes.QueryItem.inApp)
    }

}
