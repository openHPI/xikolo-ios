//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Marshal
import Result

public protocol JSONAPIValidatable: Validatable {}

extension JSONAPIValidatable {

    public static func validateServerResponse(_ resourceData: MarshalDictionary) -> Result<Void, SyncError> {
        let hasData = resourceData["data"] != nil
        let hasError = resourceData["error"] != nil
        let hasMeta = resourceData["meta"] != nil

        guard hasData || hasError || hasMeta else {
            return .failure(.api(.serialization(.topLevelEntryMissing)))
        }

        guard hasError && !hasData || !hasError && hasData else {
            return .failure(.api(.serialization(.topLevelDataAndErrorsCoexist)))
        }

        guard !hasError else {
            if let errorMessage = resourceData["error"] as? String {
                return .failure(.api(.serverError(message: errorMessage)))
            } else {
                return .failure(.api(.unknownServerError))
            }
        }

        return .success(())
    }

    public static func transformServerResponseArray(_ resourceDataArray: [MarshalDictionary]) -> MarshalDictionary {
        return ["data": resourceDataArray]
    }

}
