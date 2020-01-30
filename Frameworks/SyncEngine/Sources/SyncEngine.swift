//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Marshal

public protocol SyncEngine {

    associatedtype Networker: SyncNetworker
    associatedtype SyncEngineError: Error

    var networker: Networker { get }

    // Requests
    var baseURL: URL { get }
    var requestHeaders: [String: String] { get }

    // Core Data
    var persistentContainer: NSPersistentContainer { get }
    var persistentContainerQueue: OperationQueue { get } // this should be private and not be exposed

    func convertSyncError(_ error: SyncError) -> SyncEngineError

    // Logging
    func didSucceedOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withResult result: SyncEngineResult)
    func didFailOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withError error: SyncEngineError)

}

public extension SyncEngine {

    func didSucceedOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withResult result: SyncEngineResult) {}
    func didFailOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withError error: SyncEngineError) {}

}

public extension SyncEngine {

    private func enqueuePersistenceOperation(block: @escaping (_ context: NSManagedObjectContext) -> Void) {
        self.persistentContainerQueue.addOperation {
            let context = self.persistentContainer.newBackgroundContext()
            context.performAndWait {
                block(context)
            }
        }
    }

    private func handle<T: SyncEngineResult>(result: Result<T, SyncEngineError>, forOperation operation: SyncEngineOperation, forResourceType resourceType: String) {
        switch result {
        case let .success(syncEngineResult):
            self.didSucceedOperation(operation, forResourceType: resourceType, withResult: syncEngineResult)
        case let .failure(error):
            self.didFailOperation(operation, forResourceType: resourceType, withError: error)
        }
    }

    // MARK: - build url request

    private func buildGetRequest<Query>(forQuery query: Query) -> Result<URLRequest, SyncError> where Query: ResourceQuery, Query.Resource: Pullable  {
        guard let resourceUrl = query.resourceURL(relativeTo: self.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        guard var urlComponents = URLComponents(url: resourceUrl, resolvingAgainstBaseURL: true) else {
            return .failure(.invalidURLComponents(resourceUrl))
        }

        urlComponents.queryItems = Query.Resource.queryItems(forQuery: query)

        guard let url = urlComponents.url else {
            return .failure(.invalidURL(urlComponents.url?.absoluteString))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (header, value) in self.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    private func buildCreateRequest<Resource>(forQuery query: MultipleResourcesQuery<Resource>,
                                              forResource resource: Resource) -> Result<URLRequest, SyncError> where Resource: Pushable {
        return resource.resourceData().flatMap { self.buildCreateRequest(forQuery: query, withData: $0) }
    }

    private func buildCreateRequest<Resource>(forQuery query: MultipleResourcesQuery<Resource>,
                                              withData resourceData: Data) -> Result<URLRequest, SyncError> where Resource: Pushable {
        guard let resourceUrl = query.resourceURL(relativeTo: self.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "POST"
        request.httpBody = resourceData

        for (header, value) in self.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    private func buildSaveRequest<Resource>(forQuery query: SingleResourceQuery<Resource>,
                                            forResource resource: Resource) -> Result<URLRequest, SyncError> where Resource: Pullable & Pushable {
        guard let resourceUrl = query.resourceURL(relativeTo: self.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "PATCH"

        for (header, value) in self.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return resource.resourceData().map { data in
            request.httpBody = data
            return request
        }
    }

    private func buildDeleteRequest<Resource>(forQuery query: SingleResourceQuery<Resource>) -> Result<URLRequest, SyncError> where Resource: Pullable & Pushable {
        guard let resourceUrl = query.resourceURL(relativeTo: self.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "DELETE"

        for (header, value) in self.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    // MARK: - core data operation

    // TODO: move to DATABASE
    private func fetchCoreDataObjects<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                                inContext context: NSManagedObjectContext) -> Future<[Resource], SyncError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects)
        } catch {
            return Future(error: .coreData(error))
        }
    }

    // TODO: move to DATABASE
    private func fetchCoreDataObject<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>, inContext context: NSManagedObjectContext) -> Future<Resource?, SyncError> where Resource: NSManagedObject & Pullable {
        do {
            let objects = try context.fetch(fetchRequest)
            return Future(value: objects.first)
        } catch {
            return Future(error: .coreData(error))
        }
    }

    private func doNetworkRequest<Resource>(_ request: URLRequest, forResource: Resource.Type, expectsData: Bool = true) -> Future<NetworkResult, SyncError> where Resource: Validatable {
        let promise = Promise<NetworkResult, SyncError>()

        self.networker.perform(request: request) { data, response, error in
            if let err = error {
                promise.failure(.network(err))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                promise.failure(.api(.invalidResponse))
                return
            }

            guard 200 ... 299 ~= urlResponse.statusCode else {
                promise.failure(.api(.response(statusCode: urlResponse.statusCode, headers: urlResponse.allHeaderFields)))
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
                let resourceData: MarshalDictionary
                if let resourceDataArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [MarshalDictionary] {
                    resourceData = Resource.transformServerResponseArray(resourceDataArray)
                } else if let resourceDataObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? MarshalDictionary {
                    resourceData = resourceDataObject
                } else {
                    promise.failure(.api(.serialization(.invalidDocumentStructure)))
                    return
                }

                let result = Resource.validateServerResponse(resourceData).map {
                    return NetworkResult(resourceData: resourceData, headers: urlResponse.allHeaderFields)
                }

                promise.complete(result)
            } catch {
                promise.failure(.api(.serialization(.jsonSerialization(error))))
            }
        }

        return promise.future
    }

    // MARK: - merge

    private func mergeResources<Resource>(object: ResourceData,
                                          withExistingObjects objects: [Resource],
                                          deleteNotExistingResources: Bool,
                                          in coreDataContext: NSManagedObjectContext) -> Future<[Resource], SyncError> where Resource: NSManagedObject & Pullable {
        do {
            var existingObjects = objects
            var newObjects: [Resource] = []

            let includedResourceData = Resource.extractIncludedResourceData(from: object)
            let context = SynchronizationContext(coreDataContext: coreDataContext, includedResourceData: includedResourceData)
            let dataArray = try Resource.extractResourceData(from: object) as [ResourceData]

            for data in dataArray {
                let id = try data.value(for: Resource.resourceKeyAttribute) as String
                if var existingObject = existingObjects.first(where: { $0.id == id }) {
                    try existingObject.update(from: data, with: context)
                    if let index = existingObjects.firstIndex(of: existingObject) {
                        existingObjects.remove(at: index)
                    }

                    newObjects.append(existingObject)
                } else {
                    if var fetchedResource = try context.findExistingResource(withId: id, ofType: Resource.self) {
                        try fetchedResource.update(from: data, with: context)
                        newObjects.append(fetchedResource)
                    } else {
                        let newObject = try Resource.value(from: data, with: context)
                        newObjects.append(newObject)
                    }
                }
            }

            if deleteNotExistingResources {
                for existingObject in existingObjects {
                    coreDataContext.delete(existingObject)
                }
            }

            return Future(value: newObjects)
        } catch let error as MarshalError {
            return Future(error: .api(.serialization(.modelDeserialization(error, onType: Resource.type))))
        } catch let error as NestedMarshalError {
            return Future(error: .api(.serialization(.modelDeserialization(error, onType: Resource.type))))
        } catch let error as SynchronizationError {
            return Future(error: .synchronization(error))
        } catch {
            return Future(error: .unknown(error))
        }
    }

    private func mergeResource<Resource>(object: ResourceData,
                                         withExistingObject existingObject: Resource?,
                                         in coreDataContext: NSManagedObjectContext) -> Future<Resource, SyncError> where Resource: NSManagedObject & Pullable {
        do {
            let newObject: Resource

            let includedResourceData = Resource.extractIncludedResourceData(from: object)
            let context = SynchronizationContext(coreDataContext: coreDataContext, includedResourceData: includedResourceData)
            let data = try Resource.extractResourceData(from: object) as ResourceData

            let id = try data.value(for: Resource.resourceKeyAttribute) as String

            if var existingObject = existingObject {
                if existingObject.id == id {
                    try existingObject.update(from: data, with: context)
                    newObject = existingObject
                } else {
                    newObject = try Resource.value(from: data, with: context)
                }
            } else {
                if var fetchedResource = try context.findExistingResource(withId: id, ofType: Resource.self) {
                    try fetchedResource.update(from: data, with: context)
                    newObject = fetchedResource
                } else {
                    newObject = try Resource.value(from: data, with: context)
                }
            }

            return Future(value: newObject)
        } catch let error as MarshalError {
            return Future(error: .api(.serialization(.modelDeserialization(error, onType: Resource.type))))
        } catch let error as SynchronizationError {
            return Future(error: .synchronization(error))
        } catch {
            return Future(error: .unknown(error))
        }
    }

    // MARK: - sync

    public func synchronize<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                      withQuery query: MultipleResourcesQuery<Resource>,
                                      deleteNotExistingResources: Bool = true) -> Future<SyncMultipleResult, SyncEngineError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<SyncMultipleResult, SyncError>()

        let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
            return retry(ImmediateExecutionContext, times: 5, coolDown: DispatchTimeInterval.seconds(2)) {
                return self.doNetworkRequest(request, forResource: Resource.self)
            }
        }

        networkRequest.onSuccess { networkResult in
            self.enqueuePersistenceOperation { context in
                context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

                let coreDataFetch = self.fetchCoreDataObjects(withFetchRequest: fetchRequest, inContext: context)

                coreDataFetch.flatMap(ImmediateExecutionContext) { objects in
                    return self.mergeResources(object: networkResult.resourceData,
                                               withExistingObjects: objects,
                                               deleteNotExistingResources: deleteNotExistingResources,
                                               in: context).map { resources in
                        return MergeMultipleResult(resources: resources, headers: networkResult.headers)
                    }
                }.inject(ImmediateExecutionContext) {
                    return Result<Void, Error> {
                        return try context.save()
                    }.mapError { error in
                        return .coreData(error)
                    }
                }.map(ImmediateExecutionContext) { mergeResult in
                    return SyncMultipleResult(objectIds: mergeResult.resources.map { $0.objectID }, headers: mergeResult.headers)
                }.onComplete(ImmediateExecutionContext) { result in
                    promise.complete(result)
                }
            }
        }.onFailure { error in
            promise.failure(error)
        }

        return promise.future.mapError(self.convertSyncError).andThen { result in
            self.handle(result: result, forOperation: .sync, forResourceType: Resource.type)
        }
    }

    public func synchronize<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                      withQuery query: SingleResourceQuery<Resource>) -> Future<SyncSingleResult, SyncEngineError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<SyncSingleResult, SyncError>()

        let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
            return retry(ImmediateExecutionContext, times: 5, coolDown: DispatchTimeInterval.seconds(2)) {
                return self.doNetworkRequest(request, forResource: Resource.self)
            }
        }

        networkRequest.onSuccess { networkResult in
            self.enqueuePersistenceOperation { context in
                context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

                let coreDataFetch = self.fetchCoreDataObject(withFetchRequest: fetchRequest, inContext: context)

                coreDataFetch.flatMap(ImmediateExecutionContext) { object -> Future<MergeSingleResult<Resource>, SyncError> in
                    return self.mergeResource(object: networkResult.resourceData,
                                              withExistingObject: object,
                                              in: context).map { resource in
                        return MergeSingleResult(resource: resource, headers: networkResult.headers)
                    }
                }.inject(ImmediateExecutionContext) {
                    return Result<Void, Error> {
                        return try context.save()
                    }.mapError { error in
                        return .coreData(error)
                    }
                }.map(ImmediateExecutionContext) { mergeResult in
                    return SyncSingleResult(objectId: mergeResult.resource.objectID, headers: mergeResult.headers)
                }.onComplete(ImmediateExecutionContext) { result in
                    promise.complete(result)
                }
            }
        }.onFailure { error in
            promise.failure(error)
        }

        return promise.future.mapError(self.convertSyncError).andThen { result in
            self.handle(result: result, forOperation: .sync, forResourceType: Resource.type)
        }
    }

    // MARK: - creating

    @discardableResult
    public func createResource<Resource>(ofType resourceType: Resource.Type,
                                         withData resourceData: Data) -> Future<SyncSingleResult, SyncEngineError> where Resource: NSManagedObject & Pullable & Pushable {
        let resourceDataResult = Result<Data, SyncError>(value: resourceData)
        return self.createResource(ofType: resourceType, withData: resourceDataResult)
    }

    @discardableResult
    public func createResource<Resource>(ofType resourceType: Resource.Type,
                                        withData resourceDataResult: Result<Data, SyncError>) -> Future<SyncSingleResult, SyncEngineError> where Resource: NSManagedObject & Pullable & Pushable {
        let networkRequest = resourceDataResult.flatMap { resourceData -> Result<URLRequest, SyncError> in
            let query = MultipleResourcesQuery(type: Resource.self)
            return self.buildCreateRequest(forQuery: query, withData: resourceData)
        }.flatMap { request in
            return self.doNetworkRequest(request, forResource: Resource.self)
        }

        let promise = Promise<SyncSingleResult, SyncError>()

        self.enqueuePersistenceOperation { coreDataContext in
            coreDataContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let context = SynchronizationContext(coreDataContext: coreDataContext, includedResourceData: [])

            networkRequest.flatMap(ImmediateExecutionContext) { networkResult -> Future<SyncSingleResult, SyncError> in
                do {
                    let data = try networkResult.resourceData.value(for: "data") as ResourceData
                    let resource = try Resource.value(from: data, with: context)
                    return Future(value: SyncSingleResult(objectId: resource.objectID, headers: networkResult.headers))
                } catch let error as MarshalError {
                    return Future(error: .api(.serialization(.modelDeserialization(error, onType: Resource.type))))
                } catch let error as SynchronizationError {
                    return Future(error: .synchronization(error))
                } catch {
                    return Future(error: .unknown(error))
                }
            }.inject(ImmediateExecutionContext) {
                return Result<Void, Error> {
                    return try coreDataContext.save()
                }.mapError { error in
                    return .coreData(error)
                }
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }

        }

        return promise.future.mapError(self.convertSyncError).andThen { result in
            self.handle(result: result, forOperation: .sync, forResourceType: Resource.type)
        }
    }

    @discardableResult
    public func createResource<Resource>(_ resource: Resource) -> Future<Void, SyncEngineError> where Resource: Pushable {
        let query = MultipleResourcesQuery(type: Resource.self)
        let urlRequest = self.buildCreateRequest(forQuery: query, forResource: resource)

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request, forResource: Resource.self)
        }

        return networkRequest.mapError(self.convertSyncError).andThen { result in
            self.handle(result: result, forOperation: .sync, forResourceType: Resource.type)
        }.asVoid()
    }

    // MARK: - saving

    @discardableResult
    public func saveResource<Resource>(_ resource: Resource) -> Future<Void, SyncEngineError> where Resource: Pullable & Pushable {
        let query = SingleResourceQuery(type: Resource.self, id: resource.id)
        let urlRequest = self.buildSaveRequest(forQuery: query, forResource: resource)

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request, forResource: Resource.self)
        }

        return networkRequest.mapError(self.convertSyncError).andThen { result in
            self.handle(result: result, forOperation: .sync, forResourceType: Resource.type)
        }.asVoid()
    }

    // MARK: - deleting

    @discardableResult
    public func deleteResource<Resource>(_ resource: Resource) -> Future<Void, SyncEngineError> where Resource: Pullable & Pushable {
        let query = SingleResourceQuery(type: Resource.self, id: resource.id)
        let networkRequest = self.buildDeleteRequest(forQuery: query).flatMap { request in
            return self.doNetworkRequest(request, forResource: Resource.self, expectsData: false)
        }

        return networkRequest.mapError(self.convertSyncError).andThen { result in
            self.handle(result: result, forOperation: .sync, forResourceType: Resource.type)
        }.asVoid()
    }

}
