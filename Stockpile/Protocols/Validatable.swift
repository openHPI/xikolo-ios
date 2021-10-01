//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Marshal

public protocol Validatable {

    static func validateServerResponse(_ resourceData: MarshalDictionary) -> Result<Void, SyncError>
    static func transformServerResponseArray(_ resourceDataArray: [MarshalDictionary]) -> MarshalDictionary

}

extension Validatable {

    static func validateServerResponse(_ resourceData: MarshalDictionary) -> Result<Void, SyncError> {
        return .success(())
    }

}
