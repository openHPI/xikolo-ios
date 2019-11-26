//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import KeychainAccess
import SyncEngine

public class UserProfileHelper {

    private enum KeychainKey: String {
        case userId = "de.xikolo.ios.user-id"
        case userToken = "de.xikolo.ios.user-token"
    }

    private let keychain = Keychain(service: "de.xikolo.ios").accessibility(.afterFirstUnlock)

    public static let loginStateDidChangeNotification = Notification.Name("de.xikolo.ios.loginStateChanged")
    public static let shared = UserProfileHelper()

    public weak var delegate: UserProfileHelperDelegate?

    private init() {}

    public func login(_ email: String, password: String) -> Future<String, XikoloError> { // swiftlint:disable:this function_body_length
        let promise = Promise<String, XikoloError>()

        let parameters: String = [
            Routes.HeaderParameter.email: email,
            Routes.HeaderParameter.password: password,
        ].map { key, value in
            return "\(NetworkHelper.escape(key))=\(NetworkHelper.escape(value))"
        }.joined(separator: "&")

        var request = URLRequest(url: Routes.authenticate)
        request.httpMethod = "POST"
        request.httpBody = parameters.data(using: .utf8, allowLossyConversion: false)

        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(Routes.Header.userPlatformValue, forHTTPHeaderField: Routes.Header.userPlatformKey)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                promise.failure(.network(err))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                promise.failure(.synchronization(.api(.invalidResponse)))
                return
            }

            guard 200 ... 299 ~= urlResponse.statusCode else {
                promise.failure(.synchronization(.api(.response(statusCode: urlResponse.statusCode, headers: urlResponse.allHeaderFields))))
                return
            }

            guard let responseData = data else {
                promise.failure(.synchronization(.api(.noData)))
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    promise.failure(.synchronization(.api(.serialization(.invalidDocumentStructure))))
                    return
                }

                guard let token = json["token"] as? String, let id = json["user_id"] as? String else {
                    promise.failure(.authenticationError)
                    return
                }

                self.userToken = token
                self.userId = id
                self.postLoginStateChange()
                return promise.success(token)
            } catch {
                promise.failure(.synchronization(.api(.serialization(.jsonSerialization(error)))))
            }
        }

        self.delegate?.networkActivityStarted()
        task.resume()
        return promise.future.onComplete { _ in
            self.delegate?.networkActivityEnded()
        }
    }

    public func didLogin(withToken token: String) {
        self.userId = nil
        self.userToken = token
        self.postLoginStateChange()
    }

    public func logout() {
        self.clearKeychain()
        CoreDataHelper.clearCoreDataStorage().onFailure { error in
            ErrorManager.shared.report(error)
        }.onComplete { _ in
            self.postLoginStateChange()
        }
    }

    public var isLoggedIn: Bool {
        return !self.userToken.isEmpty
    }

    func postLoginStateChange() {
        let coursesFuture = CourseHelper.syncAllCourses().onSuccess { _ in
            AnnouncementHelper.syncAllAnnouncements()
        }

        if self.isLoggedIn {
            coursesFuture.onSuccess { _ in
                CourseDateHelper.syncAllCourseDates()
            }
        }

        if Brand.default.features.enableChannels {
            coursesFuture.onComplete { _ in
                ChannelHelper.syncAllChannels()
            }
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Self.loginStateDidChangeNotification, object: nil)
        }
    }

    public private(set) var userId: String? {
        get {
            do {
                return try self.keychain.get(KeychainKey.userId.rawValue)
            } catch {
                ErrorManager.shared.report(error)
                return nil
            }
        }
        set {
            do {
                if let value = newValue {
                    try self.keychain.set(value, key: KeychainKey.userId.rawValue)
                } else {
                    try self.keychain.remove(KeychainKey.userId.rawValue)
                }
            } catch {
                ErrorManager.shared.report(error)
            }
        }
    }

    var userToken: String {
        get {
            do {
                return try self.keychain.get(KeychainKey.userToken.rawValue) ?? ""
            } catch {
                ErrorManager.shared.report(error)
                return ""
            }
        }
        set {
            do {
                try self.keychain.set(newValue, key: KeychainKey.userToken.rawValue)
            } catch {
                ErrorManager.shared.report(error)
            }
        }
    }

    func clearKeychain() {
        do {
            try self.keychain.removeAll()
        } catch {
            log.error("Failed to clear keychain - \(error)")
            ErrorManager.shared.report(error)
        }
    }

    public func migrateLegacyKeychain() {
        let defaults = UserDefaults.standard

        let legacyUserIdKey = "user"
        if let legacyUserId = defaults.string(forKey: legacyUserIdKey), !legacyUserId.isEmpty {
            self.userId = legacyUserId
            defaults.removeObject(forKey: legacyUserIdKey)
        }

        let legacyUserTokenKey = "user_token"
        if let legacyUserToken = defaults.string(forKey: legacyUserTokenKey), !legacyUserToken.isEmpty {
            self.userToken = legacyUserToken
            defaults.removeObject(forKey: legacyUserTokenKey)
        }

        defaults.synchronize()
    }
}

public protocol UserProfileHelperDelegate: AnyObject {

    func networkActivityStarted()
    func networkActivityEnded()

}
