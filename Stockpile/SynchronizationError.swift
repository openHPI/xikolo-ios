//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Marshal

public enum SyncError: Error {
    case api(APIError)
    case coreData(Error)
    case network(Error)
    case synchronization(SynchronizationError)
    case unknown(Error)

    case invalidURL(String?)
    case invalidResourceURL
    case invalidURLComponents(URL)
}

public enum APIError: Error {
    case invalidResponse
    case noData
    case response(statusCode: Int, headers: [AnyHashable: Any])
    case unknownServerError
    case serverError(message: String)
    case serialization(SerializationError)
}

public enum SerializationError: Error {
    case invalidDocumentStructure
    case topLevelEntryMissing
    case topLevelDataAndErrorsCoexist
    case jsonSerialization(Error)
    case resourceTypeMismatch(expected: String, found: String)
    case modelDeserialization(Error, onType: String)
    case includedModelDeserialization(Error, onType: String, forIncludedType: String, forKey: String)
}

public enum SynchronizationError: Error {
    case missingIncludedResource(from: Any, to: Any, withKey: KeyType)
    case missingEntityNameForResource(Any)
}

enum NestedMarshalError: Error {
    case nestedMarshalError(Error, includeType: String, includeKey: KeyType)
}
