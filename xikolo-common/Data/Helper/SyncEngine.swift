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
        return Future(value: [])
    }

    private static func doNetworkRequest(_ request: URLRequest) -> Future<MarshaledObject, XikoloError> {
        let promise = Promise<MarshaledObject, XikoloError>()
        return promise.future
    }

    private static func merge<Resource>(object: MarshaledObject, withExistingObjects objects: [Resource], inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            var existingObjects = objects
            let data = try object.value(for: "data") as [MarshaledObject]
            let includes = try? object.value(for: "included") as [MarshaledObject]

            for d in data {
                let id = try d.value(for: "id") as String
                if let existingObject = existingObjects.first(where: { $0.id == id }) {
                    try existingObject.update(object: d, including: includes, inContext: context)
                    if let index = existingObjects.index(of: existingObject) {
                        existingObjects.remove(at: index)
                    }
                } else {
                    // TODO: do not forget to create 'resource description' model
                    let newObject = try Resource.value(from: d, including: includes, inContext: context)
                }
            }

            // TODO: delete rest of existing objects + resource identifier (cascade)

            return Future(value: existingObjects)
        } catch {
            return Future(error: XikoloError.totallyUnknownError) // TODO: better error
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
                // TODO: save core data context
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future.onComplete { _ in
            // TODO: check for api deprecation and maintance
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

protocol Pullable {

    var id: String { get set }

    static func value(from object: MarshaledObject, including includes: [MarshaledObject]?, inContext context: NSManagedObjectContext) throws -> Self

    func update(object: MarshaledObject, including includes: [MarshaledObject]?, inContext context: NSManagedObjectContext) throws
    func populate(fromObject object: MarshaledObject, including includes: [MarshaledObject]?, inContext context: NSManagedObjectContext) throws

}

extension Pullable where Self: NSManagedObject {

    static func value(from object: MarshaledObject, including includes: [MarshaledObject]?, inContext context: NSManagedObjectContext) throws -> Self {
        // TODO: add assert for resource type
        var managedObject = self.init(entity: self.entity(), insertInto: context)
        try managedObject.id = object.value(for: "id")
        try managedObject.populate(fromObject: object, including: includes, inContext: context)
        return managedObject
    }


    func update(object: MarshaledObject, including includes: [MarshaledObject]?, inContext context: NSManagedObjectContext) throws {
        try self.populate(fromObject: object, including: includes, inContext: context)
    }


    private func findIncludedObject(for objectIdentifier: ResourceIdentifier, in includes: [MarshaledObject]?) -> MarshaledObject? {
        guard let includedData = includes else {
            return nil
        }

        return includedData.first { item in
            guard let identifier = try? ResourceIdentifier(object: item) else {
                return false
            }
            return objectIdentifier.id == identifier.id && objectIdentifier.type == identifier.type
        }
    }


    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A>,
                               forKey key: KeyType,
                               fromObject object: MarshaledObject,
                               including includes: [MarshaledObject]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifier = try object.value(for: "\(key).data") as ResourceIdentifier


        // update resource
        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
            let existingObject = self[keyPath: keyPath]
            try existingObject.populate(fromObject: includedObject, including: includes, inContext: context)
        } else {
            // in this case we should throw an error. the resource should be included

            // TODO: create newObject
            // TODO: reset relationship for keyPath
            // TODO: create PendingRelationship object
            // objectId: self.objectID, relname: , desctinationObject (className: newObject.entity.managedObjectClassName, id: newObject.id)
            let rels = self.entity.relationships(forDestination: A.entity())

            guard let rel = rels.first else {
                // TODO: error: no relationship defined
            }

            guard rels.count == 1 else {
                // TODO: error too many relatiosnhips defined
            }

            let relname = rel.name
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                               forKey key: KeyType,
                               fromObject object: MarshaledObject,
                               including includes: [MarshaledObject]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
//        if let existingObject = existingObjects.first(where: { $0.id == id }) {
//            try existingObject.update(object: d, including: includes, inContext: context)
//            if let index = existingObjects.index(of: existingObject) {
//                existingObjects.remove(at: index)
//            }
//        } else {
//            // TODO: do not forget to create 'resource description' model
//            let newObject = try Resource.value(from: d, including: includes, inContext: context)
//        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, Set<A>>,
                               forKey key: KeyType,
                               fromObject object: MarshaledObject,
                               including includes: [MarshaledObject]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {

    }

}

struct ResourceIdentifier: Unmarshaling {
    let type: String
    let id: String

    init(object: MarshaledObject) throws {
        self.type = try object.value(for: "type")
        self.id = try object.value(for: "id")
    }
}
