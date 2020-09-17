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

}
