//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public enum APIStatus: Equatable {

    case standard
    case maintenance
    case deprecated(expiresOn: Date)
    case expired

    public static func == (lhs: APIStatus, rhs: APIStatus) -> Bool {
        switch (lhs, rhs) {
        case (.standard, .standard):
            return true
        case (.maintenance, .maintenance):
            return true
        case let (.deprecated(lhsDate), .deprecated(rhsDate)):
            return lhsDate == rhsDate
        case (.expired, .expired):
            return true
        default:
            return false
        }
    }

}

extension APIStatus {
    public static let didChangeNotification = Notification.Name("de.xikolo.ios.download.progressChanged")
}

public struct APIStatusNotificationKey {
    public static let status = "status"
}
