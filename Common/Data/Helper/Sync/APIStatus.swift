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
}

extension APIStatus {
    public static let didChangeNotification = Notification.Name("de.xikolo.ios.download.progressChanged")
}

public enum APIStatusNotificationKey {
    public static let status = "status"
}
