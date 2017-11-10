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

enum SynchronizationError : Error {
    case noRelationshipBetweenEnities(from: Any, to: Any)
    case toManyRelationshipBetweenEnities(from: Any, to: Any)
    case abstractRelationshipNotUpdated(from: Any, to: Any, withKey: KeyType)
    case missingIncludedResourse(from: Any, to: Any, withKey: KeyType)
}

struct SyncEngine {

    // TODO: maybe move those
    private static func buildRequest<Resource>(forQuery query: Query<Resource>) -> Future<URLRequest, XikoloError> {
        return Future { complete in
            guard let baseURL = URL(string: Routes.API_V2_URL) else { // TODO: Routes.API_V2_URL should be a URL
                complete(.failure(XikoloError.totallyUnknownError)) // TODO: better error
                return
            }

            guard let resourceUrl = URL(string: query.resourceType.type, relativeTo: baseURL) else { // TODO: dynamic query building
                complete(.failure(XikoloError.totallyUnknownError)) // TODO: better error
                return
            }

            guard var urlComponents = URLComponents(url: resourceUrl, resolvingAgainstBaseURL: true) else {
                complete(.failure(XikoloError.totallyUnknownError)) // TODO: better error
                return
            }

            var queryItems: [URLQueryItem] = []

            // includes
            if !query.includes.isEmpty {
                queryItems.append(URLQueryItem(name: "include", value: query.includes.joined(separator: ",")))
            }

            // filters
            for (key, value) in query.filters {
                let stringValue: String
                if let valueArray = value as? [Any] {
                    stringValue = valueArray.map { String(describing: $0) }.joined(separator: ",")
                } else if let value = value {
                    stringValue = String(describing: value)
                } else {
                    stringValue = "null"
                }
                let queryItem = URLQueryItem(name: "filter[\(key)]", value: stringValue)
                queryItems.append(queryItem)
            }

            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
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

    private static func fetchCoreDataObjects<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects)
        } catch {
            return Future(error: XikoloError.totallyUnknownError) // TODO: better error
        }
    }

    private static func doNetworkRequest(_ request: URLRequest) -> Future<ResourceData, XikoloError> {
        let promise = Promise<ResourceData, XikoloError>()

        let session = URLSession.shared // TODO: use custom session with configuration?
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                promise.failure(.network(err))
                return
            }

            guard let responseData = data else {
                promise.failure(.api(.noData))
                return
            }

            do {
                guard let resourceData = try JSONSerialization.jsonObject(with: responseData, options: []) as? MarshalDictionary else {
                    promise.failure(.api(.serializationError(.invalidDocumentStructure)))
                    return
                }

                let hasData = resourceData["data"] != nil
                let hasErrors = resourceData["errors"] != nil
                let hasMeta = resourceData["meta"] != nil

                guard hasData || hasErrors || hasMeta else {
                    promise.failure(.api(.serializationError(.topLevelEntryMissing)))
                    return
                }

                guard hasErrors && !hasData || !hasErrors && hasData else {
                    promise.failure(.api(.serializationError(.topLevelDataAndErrorsCoexist)))
                    return
                }

                promise.success(resourceData)
            } catch {
                promise.failure(.api(.serializationError(.jsonSerializationError(error))))
                return
            }
        }

        task.resume()
        return promise.future
    }

    private static func merge<Resource>(object: ResourceData, withExistingObjects objects: [Resource], inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            var existingObjects = objects
            var newObjects: [Resource] = []
            let data = try object.value(for: "data") as [ResourceData]
            let includes = try? object.value(for: "included") as [ResourceData]

            for d in data {
                let id = try d.value(for: "id") as String
                if let existingObject = existingObjects.first(where: { $0.id == id }) {
                    try existingObject.update(withObject: d, including: includes, inContext: context)
                    if let index = existingObjects.index(of: existingObject) {
                        existingObjects.remove(at: index)
                    }
                    newObjects.append(existingObject)
                } else {
                    let newObject = try Resource.value(from: d, including: includes, inContext: context)
                    newObjects.append(newObject)
                }
            }

            for existingObject in existingObjects {
                context.delete(existingObject)
            }

            return Future(value: newObjects)
        } catch let error as MarshalError {
            return Future(error: .api(.serializationError(.modelDeserializationError(error))))
        } catch let error as SynchronizationError {
            return Future(error: .synchronizationError(error))
        } catch {
            return Future(error: .unknownError(error))
        }
    }

    private static func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, withQuery query: Query<Resource>) -> Future<[Resource], XikoloError> {
        let promise = Promise<[Resource], XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let coreDataFetch = self.fetchCoreDataObjects(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildRequest(forQuery: query).flatMap { request in
                self.doNetworkRequest(request)
            }

            coreDataFetch.zip(networkRequest).flatMap { objects, json in
                self.merge(object: json, withExistingObjects: objects, inContext: context)
            }.flatMap { objects in
                switch CoreDataHelper.save(context) {
                case .success(_):
                    return Future(value: objects)
                case .failure(let error):
                    return Future(error: error)
                }
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future.onComplete { _ in
            // TODO: check for api deprecation and maintance
        }
    }

    static func syncCourses() -> Future<[Course], XikoloError> {
        let fetchRequest = CourseHelper.getAllCoursesRequest()
        let query = Query(type: Course.self)
        return self.syncResources(withFetchRequest: fetchRequest, withQuery: query)
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

    init(object: ResourceData) throws {
        self.type = try object.value(for: "type")
        self.id = try object.value(for: "id")
    }

}

typealias ResourceData = MarshaledObject
typealias JSON = JSONObject
typealias IncludedPullable = Unmarshaling

protocol Pullable {

    var id: String { get set }
    static var type: String { get }

    static func value(from object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws -> Self

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws

}

extension Pullable where Self: NSManagedObject {

    static func value(from object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws -> Self {
        // TODO: add assert for resource type
        var managedObject = self.init(entity: self.entity(), insertInto: context)
        try managedObject.id = object.value(for: "id")
        try managedObject.update(withObject: object, including: includes, inContext: context)
        return managedObject
    }

    private func findIncludedObject(for objectIdentifier: ResourceIdentifier, in includes: [ResourceData]?) -> ResourceData? {
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
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifier = try object.value(for: "\(key).data") as ResourceIdentifier

        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
            let existingObject = self[keyPath: keyPath]
            try existingObject.update(withObject: includedObject, including: includes, inContext: context)
        } else {
            // TODO: throw custom error: object should be included (+ try to fetch first)?
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifier = try object.value(for: "\(key).data") as ResourceIdentifier

        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
            if let existingObject = self[keyPath: keyPath] {
                try existingObject.update(withObject: includedObject, including: includes, inContext: context)
            } else {
                self[keyPath: keyPath] = try A.value(from: includedObject, including: includes, inContext: context)
            }
        } else {
            // TODO: create PendingRelationship object (+ try to fetch first)
            // objectId: self.objectID, relname: , desctinationObject (className: newObject.entity.managedObjectClassName, id: newObject.id)
            let rels = self.entity.relationships(forDestination: A.entity())

            guard let rel = rels.first else {
                throw SynchronizationError.noRelationshipBetweenEnities(from: Self.self, to: A.self)
            }

            guard rels.count == 1 else {
                throw SynchronizationError.toManyRelationshipBetweenEnities(from: Self.self, to: A.self)
            }

            let relname = rel.name
            // TODO: create pendingRelationship

            // reset current relationship
            self[keyPath: keyPath] = nil
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, Set<A>>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifiers = try object.value(for: "\(key).data") as [ResourceIdentifier]
        var currentObjects = Set(self[keyPath: keyPath])

        for resourceIdentifier in resourceIdentifiers {
            if let currentObject = currentObjects.first(where: { $0.id == resourceIdentifier.id }) {
                if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
                    try currentObject.update(withObject: includedObject, including: includes, inContext: context)
                }

                if let index = currentObjects.index(where: { $0 == currentObject }) {
                    currentObjects.remove(at: index)
                }
            } else {
                if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
                    let newObject = try A.value(from: includedObject, including: includes, inContext: context)
                    self[keyPath: keyPath].insert(newObject)
                } else {
                    // TODO: create pending relationship (+ try to fetch first)
                }
            }
        }

        for currentObject in currentObjects {
            context.delete(currentObject)
        }
    }


    func updateAbstractRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                                       forKey key: KeyType,
                                       fromObject object: ResourceData,
                                       including includes: [ResourceData]?,
                                       inContext context: NSManagedObjectContext,
                                       updatingBlock block: (AbstractPullableContainer<Self, A>) throws -> Void) throws {
        let container = AbstractPullableContainer<Self, A>(onResource: self, withKeyPath: keyPath, forKey: key, fromObject: object, including: includes, inContext: context)
        try block(container)

        guard container.wasUpdated else {
            throw SynchronizationError.abstractRelationshipNotUpdated(from: Self.self, to: A.self, withKey: key)
        }
    }


    func updateAbstractRelationship<A, B>(withContainer container: AbstractPullableContainer<Self, A>,
                                          withType: B.Type) throws where B: NSManagedObject & Pullable {
        let resourceIdentifier = try container.object.value(for: "\(container.key).data") as ResourceIdentifier

        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: container.includes) {
            guard let existingObject = self[keyPath: container.keyPath] as? B else {
                // TODO: type mismatch
                return
            }

            try existingObject.update(withObject: includedObject, including: container.includes, inContext: container.context)
            container.markAsUpdated()
        } else {
            throw SynchronizationError.missingIncludedResourse(from: Self.self, to: A.self, withKey: container.key)
        }
    }

}

class AbstractPullableContainer<A, B> where A: NSManagedObject & Pullable, B: AbstractPullable {
    let resource: A
    let keyPath: ReferenceWritableKeyPath<A, B?>
    let key: KeyType
    let object: ResourceData
    let includes: [ResourceData]?
    let context: NSManagedObjectContext
    private (set) var wasUpdated = false

    init(onResource resource: A,
         withKeyPath keyPath: ReferenceWritableKeyPath<A, B?>,
         forKey key: KeyType,
         fromObject object: ResourceData,
         including includes: [ResourceData]?,
         inContext context: NSManagedObjectContext) {
        self.resource = resource
        self.keyPath = keyPath
        self.key = key
        self.object = object
        self.includes = includes
        self.context = context
    }

    func update<C>(forType type : C.Type) throws where C : NSManagedObject & Pullable {
        // TODO: check if C can be set?
        try self.resource.updateAbstractRelationship(withContainer: self, withType: type) // TODO: catch not matching type
    }

    func markAsUpdated() {
        self.wasUpdated = true
    }
}

protocol AbstractPullable {

}

struct ResourceIdentifier: Unmarshaling {

    let type: String
    let id: String

    init(object: ResourceData) throws {
        self.type = try object.value(for: "type")
        self.id = try object.value(for: "id")
    }

}

struct Query<Resource> where Resource: NSManagedObject & Pullable {

    let resourceType: Resource.Type
    private(set) var filters: [String: Any?] = [:]
    private(set) var includes: [String] = []

    init(type: Resource.Type) {
        self.resourceType = type
    }

    mutating func addFilter(forKey key: String, withValue value: Any?) {
        self.filters[key] = value
    }

    mutating func addInclude(forKey key: String) {
        self.includes.append(key)
    }

}

