//
//  SyncEngine.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20.10.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures
import Marshal
import CoreData

struct SyncEngine {

    // TODO: maybe move those
    private static func buildRequest() -> Future<URLRequest, XikoloError> { // TODO: accept query? (or enums
        return Future { complete in
            guard let baseURL = URL(string: Routes.API_V2_URL) else { // TODO: Routes.API_V2_URL should be a URL
                complete(.failure(XikoloError.totallyUnknownError)) // TODO: better error
                return
            }

            guard let url = URL(string: "courses", relativeTo: baseURL) else { // TODO: dynamic query building
                complete(.failure(XikoloError.totallyUnknownError)) // TODO: better error
                return
            }


            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            // TODO: set headers
            // TODO: set body


            complete(.success(request))
        }
    }

    private static func fetchCoreDataObjects() -> Future<[Course], XikoloError> { // TODO: accept fetchrequest and context
        return Future { complete in
            complete(.success([]))
        }
    }

    private static func doNetworkRequest(_ request: URLRequest) -> Future<MarshaledObject, XikoloError> {
        let promise = Promise<MarshaledObject, XikoloError>()
        return promise.future
    }

    private static func merge<Resource>(object: MarshaledObject, withExistingObjects objects: [Resource], inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        var existingObjects = objects

        do {
            let data = try object.value(for: "data") as [MarshaledObject]

            for d in data {
                let id = try d.value(for: "id") as String
                if let existingObject = existingObjects.first(where: { $0.id == id }) {
                    try existingObject.update(object: d, inContext: context)
                    if let index = existingObjects.index(of: existingObject) {
                        existingObjects.remove(at: index)
                    }
                } else {
                    // TODO: do not forget to create resource description' model
                    try Resource.value(from: d, inContext: context)
                }
            }
            //


        } catch {
            return Future<[Resource], XikoloError>(error: XikoloError.totallyUnknownError) // TODO: better error
        }


        return Future { complete in
            complete(.success(existingObjects))
        }
    }

    // TODO: generic sync method for (fetchrequest, query)?
    static func syncCourses() -> Future<[Course], XikoloError> {
        let promise = Promise<[Course], XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let coreDataFetch = self.fetchCoreDataObjects()
            let networkRequest = self.buildRequest().flatMap { request in
                self.doNetworkRequest(request)
            }

            coreDataFetch.zip(networkRequest).flatMap { courses, json in
                self.merge(object: json, withExistingObjects: courses, inContext: context)
            }.onSuccess { _ in
                // save core data context
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future.onComplete { _ in
            // check for api deprecation and maintance
        }
    }
}

extension Date: ValueType {

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]
        return formatter
    }()

    public static func value(from object: Any) throws -> Date {
        guard let dateString = object as? String else {
            throw MarshalError.typeMismatch(expected: String.self, actual: type(of: object))
        }

        guard let date = Date.iso8601Formatter.date(from: dateString) else {
            throw MarshalError.typeMismatch(expected: "ISO8601 date string", actual: dateString)
        }

        return date
    }

}

struct ResourceDescription: Unmarshaling {

    let type: String
    let id: String

    init(object: MarshaledObject) throws {
        self.type = try object.value(for: "type")
        self.id = try object.value(for: "id")
    }

}

protocol Pullable: UnmarshalingWithContext, UnmarshalUpdatingWithContext {

    var id: String { get set }

    func populate(fromObject object: MarshaledObject, inContext context: NSManagedObjectContext) throws

}

extension Pullable where Self: NSManagedObject {

    @discardableResult static func value(from object: MarshaledObject, inContext context: NSManagedObjectContext) throws -> Self {
        // TODO: add assert for resource type
        var managedObject = self.init(entity: self.entity(), insertInto: context)
        try managedObject.id = object.value(for: "id")
        try managedObject.populate(fromObject: object, inContext: context)
        return managedObject
    }

    func update(object: MarshaledObject, inContext context: NSManagedObjectContext) throws {
        try self.populate(fromObject: object, inContext: context)
    }

}

protocol Pushable: Marshaling {

}

