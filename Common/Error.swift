//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Marshal
import Stockpile

public enum XikoloError: Error {
    case coreData(Error)
    case coreDataObjectNotFound
    case coreDataMoreThanOneObjectFound
    case coreDataTypeMismatch(expected: Any, found: Any)

    case invalidData
    case modelIncomplete
    case network(Error)
    case authenticationError
    case markdownError

    case invalidURL(String?)
    case invalidResourceURL
    case invalidURLComponents(URL)

    case unknownError(Error)
    case totallyUnknownError

    case synchronization(SyncError)

    case trackingForUnknownUser
    case missingResource(ofType: Any)

    case userCanceled

    var wasCausedByRestrictedNetworkConditions: Bool {
        guard case let .synchronization(syncError) = self else {
            return false
        }

        guard case let .network(networkError) = syncError else {
            return false
        }

        guard let urlError = networkError as? URLError else {
            return false
        }

        if #available(iOS 13, *) {
            return urlError.networkUnavailableReason != nil
        } else {
            return false
        }
    }

}
