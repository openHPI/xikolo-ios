//
//  Error.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
//import Spine

enum XikoloError : Error {

//    case api(SpineError)
    case api(APIError)

    case coreData(Error)
    case invalidData
    case modelIncomplete
    case network(Error)
    case authenticationError
    case markdownError

    case unknownError(Error)
    case totallyUnknownError

    case synchronizationError(SynchronizationError)
    case trackingForUnknownUser

}

enum APIError : Error {
    case noData
    case resourceNotFound // TODO where to use this?
    case serializationError(SerializationError)
//    case serverError(statusCode: Int, apiErrors: [APIError]?)
}

enum SerializationError : Error {
    /// The given JSON is not a dictionary (hash).
    case invalidDocumentStructure

    /// None of 'data', 'errors', or 'meta' is present in the top level.
    case topLevelEntryMissing

    /// Top level 'data' and 'errors' coexist in the same document.
    case topLevelDataAndErrorsCoexist

    /// The given JSON is not a dictionary (hash).
    case invalidResourceStructure

    /// 'Type' field is missing from resource JSON.
    case resourceTypeMissing

    /// 'ID' field is missing from resource JSON.
    case resourceIDMissing

    /// Error occurred in NSJSONSerialization
    case jsonSerializationError(Error)

    case modelDeserializationError(Error)
}

