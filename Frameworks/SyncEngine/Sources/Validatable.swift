//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Marshal
import Result

public protocol Validatable {

    static func validateServerResponse(_ resourceData: MarshalDictionary) -> Result<Void, SyncError>
    static func transformServerResponseArray(_ resourceDataArray: [MarshalDictionary]) -> MarshalDictionary

}

extension Validatable {

    static func validateServerResponse(_ resourceData: MarshalDictionary) -> Result<Void, SyncError> {
        return .success(())
    }

}
