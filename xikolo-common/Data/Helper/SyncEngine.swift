//
//  SyncEngine.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20.10.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures
import Result
import Marshal
import CoreData


extension Future {

    func inject(_ context: @escaping ExecutionContext = DefaultThreadingModel(), f: @escaping () -> Future<Void, Value.Error>) -> Future<Value.Value, Value.Error> {
        let promise = Promise<Value.Value, Value.Error>()

        self.onComplete(context) { result in
            switch result {
            case .success(let value):
                f().onSuccess { _ in
                    promise.success(value)
                }.onFailure { error in
                    promise.failure(error)
                }
            case .failure(let error):
                promise.failure(error)
            }
        }

        return promise.future
    }
}

extension Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

enum SynchronizationError : Error {
    case noRelationshipBetweenEnities(from: Any, to: Any)
    case toManyRelationshipBetweenEnities(from: Any, to: Any)
    case abstractRelationshipNotUpdated(from: Any, to: Any, withKey: KeyType)
    case missingIncludedResource(from: Any, to: Any, withKey: KeyType)
    case missingEnityNameForResource(Any)
}

enum NestedMarshalError: Error {
    case nestedMarshalError(Error, includeType: String, includeKey: KeyType)
}

struct SyncEngine {

    // MARK: - build url request

    private static func buildGetRequest<Query>(forQuery query: Query) -> Result<URLRequest, XikoloError> where Query: ResourceQuery {
        guard let baseURL = URL(string: Routes.API_V2_URL) else { // TODO: Routes.API_V2_URL should be a URL
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        guard let resourceUrl = query.resourceURL(relativeTo: baseURL) else {
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        guard var urlComponents = URLComponents(url: resourceUrl, resolvingAgainstBaseURL: true) else {
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
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
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (header, value) in NetworkHelper.getRequestHeaders() {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    enum SaveRequestMethod: String {
        case post = "POST"
        case patch = "PATCH"
    }

    private static func buildSaveRequest(forQuery query: ResourceURLRepresentable,
                                         withHTTPMethod httpMethod: SaveRequestMethod,
                                         forResource resource: Pushable) -> Result<URLRequest, XikoloError> {

        guard let baseURL = URL(string: Routes.API_V2_URL) else { // TODO: Routes.API_V2_URL should be a URL
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        guard let resourceUrl = query.resourceURL(relativeTo: baseURL) else {
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = httpMethod.rawValue

        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        for (header, value) in NetworkHelper.getRequestHeaders() {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return resource.resourceData().map { data in
            request.httpBody = data
            return request
        }
    }

    private static func buildDeleteRequest(forQuery query: RawSingleResourceQuery) -> Result<URLRequest, XikoloError> {

        guard let baseURL = URL(string: Routes.API_V2_URL) else { // TODO: Routes.API_V2_URL should be a URL
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        guard let resourceUrl = query.resourceURL(relativeTo: baseURL) else {
            return .failure(XikoloError.totallyUnknownError) // TODO: better error
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "DELETE"

        for (header, value) in NetworkHelper.getRequestHeaders() {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }


    // MARK: - core data operation

    private static func fetchCoreDataObjects<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects)
        } catch {
            return Future(error: .coreData(error))
        }
    }

    private static func fetchCoreDataObject<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, inContext context: NSManagedObjectContext) -> Future<Resource?, XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects.first)
        } catch {
            return Future(error: .coreData(error))
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

            guard let urlResponse = response as? HTTPURLResponse else {
                promise.failure(.api(.invalidResponse))
                return
            }

            guard 200 ... 299 ~= urlResponse.statusCode else {
                promise.failure(.api(.responseError(statusCode: urlResponse.statusCode)))
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

                // JSON:API validation
                let hasData = resourceData["data"] != nil
                let hasError = resourceData["error"] != nil
                let hasMeta = resourceData["meta"] != nil

                guard hasData || hasError || hasMeta else {
                    promise.failure(.api(.serializationError(.topLevelEntryMissing)))
                    return
                }

                guard hasError && !hasData || !hasError && hasData else {
                    promise.failure(.api(.serializationError(.topLevelDataAndErrorsCoexist)))
                    return
                }

                guard !hasError else {
                    if let errorMessage = resourceData["error"] as? String {
                        promise.failure(.api(.serverError(message: errorMessage)))
                    } else {
                        promise.failure(.api(.unknownServerError))
                    }
                    return
                }

                promise.success(resourceData)
            } catch {
                promise.failure(.api(.serializationError(.jsonSerializationError(error))))
            }
        }

        NetworkIndicator.start()
        task.resume()
        return promise.future.onComplete { _ in
            NetworkIndicator.end()
        }
    }

    // MARK: - merge

    private static func mergeResources<Resource>(object: ResourceData, withExistingObjects objects: [Resource], inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            var existingObjects = objects
            var newObjects: [Resource] = []
            let dataArray = try object.value(for: "data") as [ResourceData]
            let includes = try? object.value(for: "included") as [ResourceData]

            for data in dataArray {
                let id = try data.value(for: "id") as String
                if var existingObject = existingObjects.first(where: { $0.id == id }) {
                    try existingObject.update(withObject: data, including: includes, inContext: context)
                    if let index = existingObjects.index(of: existingObject) {
                        existingObjects.remove(at: index)
                    }
                    newObjects.append(existingObject)
                } else {
                    if var fetchedResource = try self.findExistingResource(withId: id, ofType: Resource.self, inContext: context) {
                        try fetchedResource.update(withObject: data, including: includes, inContext: context)
                        newObjects.append(fetchedResource)
                    } else {
                        let newObject = try Resource.value(from: data, including: includes, inContext: context)
                        newObjects.append(newObject)
                    }
                }
            }

            for existingObject in existingObjects {
                context.delete(existingObject)
            }

            return Future(value: newObjects)
        } catch let error as MarshalError {
            return Future(error: .api(.serializationError(.modelDeserializationError(error, onType: Resource.type))))
        } catch let error as NestedMarshalError {
            return Future(error: .api(.serializationError(.modelDeserializationError(error, onType: Resource.type))))
        } catch let error as SynchronizationError {
            return Future(error: .synchronizationError(error))
        } catch {
            return Future(error: .unknownError(error))
        }
    }

    private static func mergeResource<Resource>(object: ResourceData, withExistingObject existingObject: Resource?, inContext context: NSManagedObjectContext) -> Future<Resource, XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            let newObject: Resource
            let data = try object.value(for: "data") as ResourceData
            let includes = try? object.value(for: "included") as [ResourceData]

            guard let id = try? data.value(for: "id") as String else {
                return Future(error: .api(.resourceNotFound))
            }

            if var existingObject = existingObject {
                if existingObject.id == id {
                    try existingObject.update(withObject: data, including: includes, inContext: context)
                    newObject = existingObject
                } else {
                    newObject = try Resource.value(from: data, including: includes, inContext: context)
                }
            } else {
                if var fetchedResource = try self.findExistingResource(withId: id, ofType: Resource.self, inContext: context) {
                    try fetchedResource.update(withObject: data, including: includes, inContext: context)
                    newObject = fetchedResource
                } else {
                    newObject = try Resource.value(from: data, including: includes, inContext: context)
                }
            }

            return Future(value: newObject)
        } catch let error as MarshalError {
            return Future(error: .api(.serializationError(.modelDeserializationError(error, onType: Resource.type))))
        } catch let error as SynchronizationError {
            return Future(error: .synchronizationError(error))
        } catch {
            return Future(error: .unknownError(error))
        }
    }

    // MARK: - sync

    static func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, withQuery query: MultipleResourcesQuery<Resource>) -> Future<[NSManagedObjectID], XikoloError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<[NSManagedObjectID], XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let coreDataFetch = self.fetchCoreDataObjects(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
                return self.doNetworkRequest(request)
            }

            coreDataFetch.zip(networkRequest).flatMap { objects, json in
                return self.mergeResources(object: json, withExistingObjects: objects, inContext: context)
            }.inject {
                do {
                    try context.save()
                    return Future(value: ())
                } catch {
                    return Future(error: .coreData(error))
                }
            }.map { objects in
                return objects.map { $0.objectID }
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future.onSuccess { _ in
            // TODO: log something cool
            print("Verbose: Successfully merged resources of type: \(Resource.type)")
        }.onFailure { error in
            print("Error: Failed to sync resources of type: \(Resource.type) ==> \(error)")
        }
    }

    static func syncResource<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, withQuery query: SingleResourceQuery<Resource>) -> Future<NSManagedObjectID, XikoloError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<NSManagedObjectID, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let coreDataFetch = self.fetchCoreDataObject(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
                return self.doNetworkRequest(request)
            }

            coreDataFetch.zip(networkRequest).flatMap { object, json -> Future<Resource, XikoloError> in
                return self.mergeResource(object: json, withExistingObject: object, inContext: context)
            }.inject {
                do {
                    try context.save()
                    return Future(value: ())
                } catch {
                    return Future(error: .coreData(error))
                }
            }.map { object in
                return object.objectID
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future.onSuccess { _ in
            // TODO: log something cool
            print("Verbose: Successfully merged resource of type: \(Resource.type)")
        }.onFailure { error in
            print("Error: Failed to sync resource of type: \(Resource.type) ==> \(error)")
        }
    }

    // MARK: - saving

    @discardableResult static func saveResource(_ resource: Pushable) -> Future<Void, XikoloError> {
        let resourceType = type(of: resource).type
        let query = RawMultipleResourcesQuery(type: resourceType)
        let networkRequest = self.buildSaveRequest(forQuery: query, withHTTPMethod: .post, forResource: resource).flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.onSuccess { _ in
            // TODO: log something cool
            print("Verbose: Successfully saved resource of type: \(resourceType)")
        }.onFailure { error in
            print("Error: Failed to save resource of type: \(resourceType) ==> \(error)")
        }.asVoid()
    }

    @discardableResult static func saveResource(_ resource: Pushable & Pullable) -> Future<Void, XikoloError> {
        let resourceType = type(of: resource).type
        let urlRequest: Result<URLRequest, XikoloError>
        if resource.objectState == .new {
            let query = RawMultipleResourcesQuery(type: resourceType)
            urlRequest = self.buildSaveRequest(forQuery: query, withHTTPMethod: .post, forResource: resource)
        } else {
            let query = RawSingleResourceQuery(type: resourceType, id: resource.id)
            urlRequest = self.buildSaveRequest(forQuery: query, withHTTPMethod: .patch, forResource: resource)
        }

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.onSuccess { _ in
            // TODO: log something cool
            print("Verbose: Successfully saved resource of type: \(resourceType)")
        }.onFailure { error in
            print("Error: Failed to save resource of type: \(resourceType) ==> \(error)")
        }.asVoid()
    }

    // MARK: - deleting

    @discardableResult static func deleteResource(_ resource: Pushable & Pullable) -> Future<Void, XikoloError> {
        let resourceType = type(of: resource).type
        let query = RawSingleResourceQuery(type: resourceType, id: resource.id)
        let networkRequest = self.buildDeleteRequest(forQuery: query).flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.onSuccess { _ in
            // TODO: log something cool
            print("Verbose: Successfully deleted resource of type: \(resourceType)")
        }.onFailure { error in
            print("Error: Failed to delete resource: \(resource) ==> \(error)")
        }.asVoid()
    }

    static func findExistingResource<Resource>(withId objectId: String,
                                               ofType type: Resource.Type,
                                               inContext context: NSManagedObjectContext) throws -> Resource? where Resource: NSManagedObject & Pullable {
        guard let entityName = Resource.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(Resource.self)
        }

        let fetchRequest: NSFetchRequest<Resource> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", objectId)

        let objects = try context.fetch(fetchRequest)

        if objects.count > 1 {
            print("Warning: Found multiple resources while updating relationship (entity name: \(entityName), \(objectId))")
        }

        return objects.first
    }

}

// MARK: - ValueTypes

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

protocol ResourceTypeRepresentable {
    static var type: String { get }
}

protocol ResourceRepresentable: ResourceTypeRepresentable {
    var id: String { get set }

    var identifier: [String: String] { get }
}


extension ResourceRepresentable {

    var identifier: [String: String] {
        return [
            "type": Self.type,
            "id": self.id,
        ]
    }

}

// MARK: - Pullable

protocol Pullable : ResourceRepresentable {

    static func value(from object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws -> Self

    mutating func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws

}

extension Pullable where Self: NSManagedObject {

    static func value(from object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws -> Self {
        // TODO: add assert for resource type
        var managedObject = self.init(entity: self.entity(), insertInto: context)
        try managedObject.id = object.value(for: "id")
        try managedObject.update(withObject: object, including: includes, inContext: context)
        return managedObject
    }

    fileprivate func findIncludedObject(for objectIdentifier: ResourceIdentifier, in includes: [ResourceData]?) -> ResourceData? {
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
            var existingObject = self[keyPath: keyPath]
            do {
                try existingObject.update(withObject: includedObject, including: includes, inContext: context)
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
            }
        } else {
            throw SynchronizationError.missingIncludedResource(from: Self.self, to: A.self, withKey: key)
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, A?>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        guard let resourceIdentifier = try? object.value(for: "\(key).data") as ResourceIdentifier else {
            self[keyPath: keyPath] = nil
            // TODO: logging
            return
        }


        if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
            do {
                if var existingObject = self[keyPath: keyPath] {
                    try existingObject.update(withObject: includedObject, including: includes, inContext: context)
                } else {
                    if var fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                        try fetchedResource.update(withObject: includedObject, including: includes, inContext: context)
                        self[keyPath: keyPath] = fetchedResource
                    } else {
                        self[keyPath: keyPath] = try A.value(from: includedObject, including: includes, inContext: context)
                    }
                }
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
            }
        } else {
            if let fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                self[keyPath: keyPath] = fetchedResource
            } else {
//                try PendingRelationship(origin: self, destination: resourceIdentifier, destinationType: A.self, toManyRelationship: false, inContext: context)
                print("Create pending relationship")
            }
        }
    }

    func updateRelationship<A>(forKeyPath keyPath: ReferenceWritableKeyPath<Self, Set<A>>,
                               forKey key: KeyType,
                               fromObject object: ResourceData,
                               including includes: [ResourceData]?,
                               inContext context: NSManagedObjectContext) throws where A: NSManagedObject & Pullable {
        let resourceIdentifiers = try object.value(for: "\(key).data") as [ResourceIdentifier]
        var currentObjects = Set(self[keyPath: keyPath])

        do {
            for resourceIdentifier in resourceIdentifiers {
                if var currentObject = currentObjects.first(where: { $0.id == resourceIdentifier.id }) {
                    if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
                        try currentObject.update(withObject: includedObject, including: includes, inContext: context)
                    }

                    if let index = currentObjects.index(where: { $0 == currentObject }) {
                        currentObjects.remove(at: index)
                    }
                } else {
                    if let includedObject = self.findIncludedObject(for: resourceIdentifier, in: includes) {
                        if var fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                            try fetchedResource.update(withObject: includedObject, including: includes, inContext: context)
                            self[keyPath: keyPath].insert(fetchedResource)
                        } else {
                            let newObject = try A.value(from: includedObject, including: includes, inContext: context)
                            self[keyPath: keyPath].insert(newObject)
                        }
                    } else {
                        if let fetchedResource = try SyncEngine.findExistingResource(withId: resourceIdentifier.id, ofType: A.self, inContext: context) {
                            self[keyPath: keyPath].insert(fetchedResource)
                        } else {
//                            try PendingRelationship(origin: self, destination: resourceIdentifier, destinationType: A.self, toManyRelationship: true, inContext: context)
                            print("Create pending relationship")
                        }
                    }
                }
            }
        } catch let error as MarshalError {
            throw NestedMarshalError.nestedMarshalError(error, includeType: A.type, includeKey: key)
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
        let resourceIdentifier = try self.object.value(for: "\(self.key).data") as ResourceIdentifier

        guard resourceIdentifier.type == C.type else { return }

        if let includedObject = self.resource.findIncludedObject(for: resourceIdentifier, in: self.includes) {
            do {
                if var existingObject = self.resource[keyPath: self.keyPath] as? C{
                    try existingObject.update(withObject: includedObject, including: includes, inContext: context)
                    self.markAsUpdated()
                } else if let newObject = try C.value(from: includedObject, including: includes, inContext: context) as? B {
                    self.resource[keyPath: self.keyPath] = newObject
                    self.markAsUpdated()
                }
            } catch let error as MarshalError {
                throw NestedMarshalError.nestedMarshalError(error, includeType: C.type, includeKey: key)
            }
        } else {
            throw SynchronizationError.missingIncludedResource(from: A.self, to: B.self, withKey: self.key)
        }
    }

    func markAsUpdated() {
        self.wasUpdated = true
    }
}

protocol AbstractPullable {}

// MARK: - Pushable

enum ObjectState: Int16 {
    case unchanged = 0
    case new
    case modified
    case deleted
}

protocol IncludedPushable {
    func resourceAttributes() -> [String: Any]
}

protocol Pushable : ResourceTypeRepresentable, IncludedPushable, NSFetchRequestResult {
    var objectState: ObjectState { get }
    var deleteAfterSync: Bool { get }

    func resourceData() -> Result<Data, XikoloError>
    func resourceRelationships() -> [String: AnyObject]?
    func markAsUnchanged()
}

extension Pushable {

    var deleteAfterSync: Bool {
        return false
    }

    func resourceData() -> Result<Data, XikoloError> {
        do {
            var data: [String: Any] = [ "type": Self.type ]
            if let newResource = self as? ResourceRepresentable, self.objectState != .new {
                data["id"] = newResource.id
            }

            data["attributes"] = self.resourceAttributes()
            if let resourceRelationships = self.resourceRelationships() {
                var relationships: [String: Any] = [:]
                for (relationshipName, object) in resourceRelationships {
                    if let resource = object as? ResourceRepresentable {
                        relationships[relationshipName] = ["data": resource.identifier]
                    } else if let resources = object as? [ResourceRepresentable] {
                        relationships[relationshipName] = ["data": resources.map { $0.identifier }]
                    }
                }
                if !relationships.isEmpty {
                    data["relationships"] = relationships
                }
            }

            let json = [ "data": data ]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            return .success(jsonData)
        } catch {
            return .failure(.api(.serializationError(.jsonSerializationError(error))))
        }
    }

    func resourceRelationships() -> [String: AnyObject]? {
        return nil
    }

}

// MARK: - ResourceIdentifier

struct ResourceIdentifier: Unmarshaling {

    let type: String
    let id: String

    init(object: ResourceData) throws {
        self.type = try object.value(for: "type")
        self.id = try object.value(for: "id")
    }

}

// MARK: - ResourceQuery

protocol ResourceURLRepresentable {
    func resourceURL(relativeTo baseURL: URL) -> URL?
}

protocol ResourceQuery: ResourceURLRepresentable {
    associatedtype Resource

    var resourceType: Resource.Type { get }
    var filters: [String: Any?] { get set }
    var includes: [String] { get set }

    mutating func addFilter(forKey key: String, withValue value: Any?)
    mutating func include(_ key: String)

    func resourceURL(relativeTo baseURL: URL) -> URL?
}

extension ResourceQuery {
    mutating func addFilter(forKey key: String, withValue value: Any?) {
        self.filters[key] = value
    }

    mutating func include(_ key: String) {
        self.includes.append(key)
    }
}

struct SingleResourceQuery<Resource> : ResourceQuery where Resource: ResourceRepresentable {

    let id: String
    let resourceType: Resource.Type
    var filters: [String: Any?] = [:]
    var includes: [String] = []

    init(resource: Resource) {
        self.id = resource.id
        self.resourceType = Resource.self
    }

    init(type: Resource.Type, id: String) {
        self.id = id
        self.resourceType = type
    }

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.resourceType.type).appendingPathComponent(self.id)
    }

}

struct MultipleResourcesQuery<Resource> : ResourceQuery where Resource: ResourceTypeRepresentable {

    let resourceType: Resource.Type
    var filters: [String: Any?] = [:]
    var includes: [String] = []

    init(type: Resource.Type) {
        self.resourceType = type
    }

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.resourceType.type)
    }

}

struct RawSingleResourceQuery: ResourceURLRepresentable {
    let type: String
    let id: String

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.type).appendingPathComponent(self.id)
    }
}

struct RawMultipleResourcesQuery: ResourceURLRepresentable {
    let type: String

    func resourceURL(relativeTo baseURL: URL) -> URL? {
        return baseURL.appendingPathComponent(self.type)
    }
}


extension NSManagedObject {

    func notifyOnChange(_ observer: UIViewController,
                        updateHandler: @escaping ModelObserver.UpdateHandler,
                        deleteHandler: @escaping ModelObserver.DeleteHandler) {
        ModelObserverManager.shared.notifyOnChange(forObject: self, forObserver: observer, updateHandler: updateHandler, deleteHandler: deleteHandler)
    }

    func removeNotifications(_ observer: UIViewController) {
        ModelObserverManager.shared.removeNotifications(forObject: self, forObserver: observer)
    }

}

class ModelObserverManager {

    static let shared = ModelObserverManager()

    struct ModelObeserverKey: Hashable {
        let viewController: UIViewController
        let objectId: NSManagedObjectID

        var hashValue: Int {
            return self.viewController.hashValue ^ self.objectId.hashValue
        }

        static func ==(lhs: ModelObserverManager.ModelObeserverKey, rhs: ModelObserverManager.ModelObeserverKey) -> Bool {
            return lhs.viewController == rhs.viewController && lhs.objectId == rhs.objectId
        }
    }

    private var modelObservers: [ModelObeserverKey: ModelObserver] = [:]

    func notifyOnChange(forObject object: NSManagedObject,
                        forObserver observer: UIViewController,
                        updateHandler: @escaping ModelObserver.UpdateHandler,
                        deleteHandler: @escaping ModelObserver.DeleteHandler) {
        let key = ModelObeserverKey(viewController: observer, objectId: object.objectID)
        let modelObserver = ModelObserver(model: object, updateHandler: updateHandler, deleteHandler: deleteHandler)
        NotificationCenter.default.addObserver(modelObserver,
                                               selector: #selector(ModelObserver.dataModelDidChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: object.managedObjectContext ?? CoreDataHelper.viewContext)
        self.modelObservers[key] = modelObserver
    }

    func removeNotifications(forObject object: NSManagedObject, forObserver observer: UIViewController) {
        let key = ModelObeserverKey(viewController: observer, objectId: object.objectID)
        if let modelObserver = self.modelObservers[key] {
            NotificationCenter.default.removeObserver(modelObserver)
            self.modelObservers.removeValue(forKey: key)
        }
    }
}

class ModelObserver {

    typealias UpdateHandler = () -> ()
    typealias DeleteHandler = () -> ()

    var model: NSManagedObject
    var updateHandler: UpdateHandler
    var deleteHandler: DeleteHandler

    init(model: NSManagedObject, updateHandler: @escaping UpdateHandler, deleteHandler: @escaping DeleteHandler) {
        self.model = model
        self.updateHandler = updateHandler
        self.deleteHandler = deleteHandler
    }

    @objc func dataModelDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No user info provided in notification")
            return
        }

        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updatedObjects.contains(self.model) {
            self.updateHandler()
        } else if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletedObjects.contains(self.model) {
            self.deleteHandler()
        }
    }

}

