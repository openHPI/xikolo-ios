//
//  Error.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Marshal

enum XikoloError : Error {
    case api(APIError)

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

    case synchronizationError(SynchronizationError)
    case trackingForUnknownUser
    case missingResource(ofType: Any)
}

enum APIError : Error {
    case invalidResponse
    case noData
    case responseError(statusCode: Int)
    case unknownServerError
    case serverError(message: String)
    case resourceNotFound
    case serializationError(SerializationError)
}

enum SerializationError : Error {
    case invalidDocumentStructure
    case topLevelEntryMissing
    case topLevelDataAndErrorsCoexist
    case jsonSerializationError(Error)
    case resourceTypeMismatch(expected: String, found: String)
    case modelDeserializationError(Error, onType: String)
    case includedModelDeserializationError(Error, onType: String, forIncludedType: String, forKey: String)
}

enum SynchronizationError : Error {
    case noRelationshipBetweenEnities(from: Any, to: Any)
    case toManyRelationshipBetweenEnities(from: Any, to: Any)
    case abstractRelationshipNotUpdated(from: Any, to: Any, withKey: KeyType)
    case missingIncludedResource(from: Any, to: Any, withKey: KeyType)
    case missingEnityNameForResource(Any)
    case noMatchAbstractType(resourceType: Any, abstractType: Any)
}

enum NestedMarshalError: Error {
    case nestedMarshalError(Error, includeType: String, includeKey: KeyType)
}

