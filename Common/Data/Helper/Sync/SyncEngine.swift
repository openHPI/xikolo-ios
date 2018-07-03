//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length line_length function_body_length type_body_length

import BrightFutures
import CoreData
import Foundation
import Marshal
import Result

public class SyncEngine {

    public struct SyncMultipleResult {
        public let objectIds: [NSManagedObjectID]
        public let headers: [AnyHashable: Any]
    }

    public struct SyncSingleResult {
        public let objectId: NSManagedObjectID
        public let headers: [AnyHashable: Any]
    }

    private struct MergeMultipleResult<Resource> where Resource: NSManagedObject & Pullable {
        let resources: [Resource]
        let headers: [AnyHashable: Any]
    }

    private struct MergeSingleResult<Resource> where Resource: NSManagedObject & Pullable {
        let resource: Resource
        let headers: [AnyHashable: Any]
    }

    private struct NetworkResult {
        let resourceData: ResourceData
        let headers: [AnyHashable: Any]
    }

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 300
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }

        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    public static let shared = SyncEngine()

    public var delegate: SyncEngineDelegate?

    private init() {}

    // MARK: - build url request

    private func buildGetRequest<Query>(forQuery query: Query) -> Result<URLRequest, XikoloError> where Query: ResourceQuery {
        guard let resourceUrl = query.resourceURL(relativeTo: Routes.api) else {
            return .failure(.invalidResourceURL)
        }

        guard var urlComponents = URLComponents(url: resourceUrl, resolvingAgainstBaseURL: true) else {
            return .failure(.invalidURLComponents(resourceUrl))
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
            return .failure(.invalidURL(urlComponents.url?.absoluteString))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (header, value) in NetworkHelper.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    private func buildCreateRequest(forQuery query: ResourceURLRepresentable,
                                    forResource resource: Pushable) -> Result<URLRequest, XikoloError> {
        switch resource.resourceData() {
        case let .success(resourceData):
            return self.buildCreateRequest(forQuery: query, withData: resourceData)
        case let .failure(error):
            return .failure(error)
        }
    }

    private func buildCreateRequest(forQuery query: ResourceURLRepresentable,
                                    withData resourceData: Data) -> Result<URLRequest, XikoloError> {
        guard let resourceUrl = query.resourceURL(relativeTo: Routes.api) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "POST"
        request.httpBody = resourceData

        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        for (header, value) in NetworkHelper.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    private func buildSaveRequest(forQuery query: ResourceURLRepresentable,
                                  forResource resource: Pushable) -> Result<URLRequest, XikoloError> {
        guard let resourceUrl = query.resourceURL(relativeTo: Routes.api) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "PATCH"

        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        for (header, value) in NetworkHelper.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return resource.resourceData().map { data in
            request.httpBody = data
            return request
        }
    }

    private func buildDeleteRequest(forQuery query: RawSingleResourceQuery) -> Result<URLRequest, XikoloError> {
        guard let resourceUrl = query.resourceURL(relativeTo: Routes.api) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "DELETE"

        for (header, value) in NetworkHelper.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    // MARK: - core data operation

    private func fetchCoreDataObjects<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects)
        } catch {
            return Future(error: .coreData(error))
        }
    }

    private func fetchCoreDataObject<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, inContext context: NSManagedObjectContext) -> Future<Resource?, XikoloError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects.first)
        } catch {
            return Future(error: .coreData(error))
        }
    }

    private func doNetworkRequest(_ request: URLRequest, expectsData: Bool = true) -> Future<NetworkResult, XikoloError> {
        let promise = Promise<NetworkResult, XikoloError>()

        let task = self.session.dataTask(with: request) { data, response, error in
            if let err = error {
                promise.failure(.network(err))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                promise.failure(.api(.invalidResponse))
                return
            }

            guard 200 ... 299 ~= urlResponse.statusCode else {
                promise.failure(.api(.responseError(statusCode: urlResponse.statusCode, headers: urlResponse.allHeaderFields)))
                return
            }

            guard expectsData else {
                let result = NetworkResult(resourceData: [:], headers: urlResponse.allHeaderFields)
                return promise.success(result)
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

                let result = NetworkResult(resourceData: resourceData, headers: urlResponse.allHeaderFields)
                promise.success(result)
            } catch {
                promise.failure(.api(.serializationError(.jsonSerializationError(error))))
            }
        }

        self.delegate?.networkActivityStarted()
        task.resume()
        return promise.future.onComplete { _ in
            self.delegate?.networkActivityEnded()
        }
    }

    // MARK: - merge

    private func mergeResources<Resource>(object: ResourceData, withExistingObjects objects: [Resource], deleteNotExistingResources: Bool, inContext context: NSManagedObjectContext) -> Future<[Resource], XikoloError> where Resource: NSManagedObject & Pullable {
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

            if deleteNotExistingResources {
                for existingObject in existingObjects {
                    context.delete(existingObject)
                }
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

    private func mergeResource<Resource>(object: ResourceData, withExistingObject existingObject: Resource?, inContext context: NSManagedObjectContext) -> Future<Resource, XikoloError> where Resource: NSManagedObject & Pullable {
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

    func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, withQuery query: MultipleResourcesQuery<Resource>, deleteNotExistingResources: Bool = true) -> Future<SyncMultipleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<SyncMultipleResult, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let coreDataFetch = self.fetchCoreDataObjects(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
                return retry(ImmediateExecutionContext, times: 5, coolDown: DispatchTimeInterval.seconds(2)) {
                    return self.doNetworkRequest(request)
                }
            }

            coreDataFetch.zip(networkRequest).flatMap(ImmediateExecutionContext) { objects, networkResult in
                return self.mergeResources(object: networkResult.resourceData, withExistingObjects: objects, deleteNotExistingResources: deleteNotExistingResources, inContext: context).map { resources in
                    return MergeMultipleResult(resources: resources, headers: networkResult.headers)
                }
            }.inject(ImmediateExecutionContext) {
                do {
                    try context.save()
                    return Future(value: ())
                } catch {
                    return Future(error: .coreData(error))
                }
            }.map(ImmediateExecutionContext) { mergeResult in
                return SyncMultipleResult(objectIds: mergeResult.resources.map { $0.objectID }, headers: mergeResult.headers)
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }
        }

        return promise.future.onSuccess { result in
            self.delegate?.didSynchronizeResources(ofType: Resource.type, withResult: result)
        }.onFailure { error in
            self.delegate?.didFailToSynchronizeResources(ofType: Resource.type, withError: error)
        }
    }

    func syncResource<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, withQuery query: SingleResourceQuery<Resource>) -> Future<SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<SyncSingleResult, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let coreDataFetch = self.fetchCoreDataObject(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
                return retry(ImmediateExecutionContext, times: 5, coolDown: DispatchTimeInterval.seconds(2)) {
                    return self.doNetworkRequest(request)
                }
            }

            coreDataFetch.zip(networkRequest).flatMap(ImmediateExecutionContext) { object, networkResult -> Future<MergeSingleResult<Resource>, XikoloError> in
                return self.mergeResource(object: networkResult.resourceData, withExistingObject: object, inContext: context).map { resource in
                    return MergeSingleResult(resource: resource, headers: networkResult.headers)
                }
            }.inject(ImmediateExecutionContext) {
                do {
                    try context.save()
                    return Future(value: ())
                } catch {
                    return Future(error: .coreData(error))
                }
            }.map(ImmediateExecutionContext) { mergeResult in
                return SyncSingleResult(objectId: mergeResult.resource.objectID, headers: mergeResult.headers)
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }
        }

        return promise.future.onSuccess { result in
            self.delegate?.didSynchronizeResource(ofType: Resource.type, withResult: result)
        }.onFailure { error in
            self.delegate?.didFailToSynchronizeResource(ofType: Resource.type, withError: error)
        }
    }

    // MARK: - creating

    @discardableResult func createResource<Resource>(ofType resourceType: Resource.Type, withData resourceData: Data) -> Future<SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable & Pushable {
        let query = RawMultipleResourcesQuery(type: Resource.type)
        let networkRequest = self.buildCreateRequest(forQuery: query, withData: resourceData).flatMap { request in
            return self.doNetworkRequest(request)
        }

        let promise = Promise<SyncSingleResult, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            networkRequest.flatMap(ImmediateExecutionContext) { networkResult -> Future<SyncSingleResult, XikoloError> in
                do {
                    let data = try networkResult.resourceData.value(for: "data") as ResourceData
                    let resource = try Resource.value(from: data, including: [], inContext: context)
                    return Future(value: SyncSingleResult(objectId: resource.objectID, headers: networkResult.headers))
                } catch let error as MarshalError {
                    return Future(error: .api(.serializationError(.modelDeserializationError(error, onType: Resource.type))))
                } catch let error as SynchronizationError {
                    return Future(error: .synchronizationError(error))
                } catch {
                    return Future(error: .unknownError(error))
                }
            }.inject(ImmediateExecutionContext) {
                do {
                    try context.save()
                    return Future(value: ())
                } catch {
                    return Future(error: .coreData(error))
                }
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }

        }

        return promise.future.onSuccess { _ in
            self.delegate?.didCreateResource(ofType: Resource.type)
        }.onFailure { error in
            self.delegate?.didFailToCreateResource(ofType: Resource.type, withError: error)
        }
    }

    @discardableResult func createResource(_ resource: Pushable) -> Future<Void, XikoloError> {
        let resourceType = type(of: resource).type
        let query = RawMultipleResourcesQuery(type: resourceType)
        let networkRequest = self.buildCreateRequest(forQuery: query, forResource: resource).flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.asVoid().onSuccess { _ in
            self.delegate?.didCreateResource(ofType: resourceType)
        }.onFailure { error in
            self.delegate?.didFailToCreateResource(ofType: resourceType, withError: error)
        }
    }

    // MARK: - saving

    @discardableResult func saveResource(_ resource: Pullable & Pushable) -> Future<Void, XikoloError> {
        let resourceType = type(of: resource).type
        let query = RawSingleResourceQuery(type: resourceType, id: resource.id)
        let urlRequest = self.buildSaveRequest(forQuery: query, forResource: resource)

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.asVoid().onSuccess { _ in
            self.delegate?.didSaveResource(ofType: resourceType)
        }.onFailure { error in
            self.delegate?.didFailToSaveResource(ofType: resourceType, withError: error)
        }
    }

    // MARK: - deleting

    @discardableResult func deleteResource(_ resource: Pullable & Pushable) -> Future<Void, XikoloError> {
        let resourceType = type(of: resource).type
        let query = RawSingleResourceQuery(type: resourceType, id: resource.id)
        let networkRequest = self.buildDeleteRequest(forQuery: query).flatMap { request in
            return self.doNetworkRequest(request, expectsData: false)
        }

        return networkRequest.asVoid().onSuccess { _ in
            self.delegate?.didDeleteResource(ofType: resourceType)
        }.onFailure { error in
            self.delegate?.didFailToDeleteResource(ofType: resourceType, withError: error)
        }
    }

    func findExistingResource<Resource>(withId objectId: String,
                                        ofType type: Resource.Type,
                                        inContext context: NSManagedObjectContext) throws -> Resource? where Resource: NSManagedObject & Pullable {
        guard let entityName = Resource.entity().name else {
            throw SynchronizationError.missingEnityNameForResource(Resource.self)
        }

        let fetchRequest: NSFetchRequest<Resource> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", objectId)

        let objects = try context.fetch(fetchRequest)

        if objects.count > 1 {
            log.warning("Found multiple resources while updating relationship (entity name: \(entityName), \(objectId))")
        }

        return objects.first
    }

}
