//
//  Created for schulcloud-mobile-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Marshal
import Result

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


public struct SyncEngine<Configuration, Strategy> where Configuration: SyncConfig, Strategy: SyncStrategy {

//    static var networkActivity: ((SyncNetworkActivityType) -> Void)?

//    enum SyncNetworkActivityType {
//        case start
//        case stop
//    }
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 300
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }

        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    let configuration: Configuration
    let strategy: Strategy

    public init(configuration: Configuration, strategy: Strategy) {
        self.configuration = configuration
        self.strategy = strategy
    }

    // MARK: - build url request

    private func buildGetRequest<Query>(forQuery query: Query) -> Result<URLRequest, SyncError> where Query: ResourceQuery {
        guard let resourceUrl = query.resourceURL(relativeTo: configuration.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        guard var urlComponents = URLComponents(url: resourceUrl, resolvingAgainstBaseURL: true) else {
            return .failure(.invalidURLComponents(resourceUrl))
        }

        urlComponents.queryItems = self.strategy.queryItems(forQuery: query)

        guard let url = urlComponents.url else {
            return .failure(.invalidURL(urlComponents.url?.absoluteString))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        for (header, value) in self.configuration.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    private func buildCreateRequest(forQuery query: ResourceURLRepresentable,
                                    forResource resource: Pushable) -> Result<URLRequest, SyncError> {
        switch self.strategy.resourceData(for: resource) {
        case let .success(resourceData):
            return self.buildCreateRequest(forQuery: query, withData: resourceData)
        case let .failure(error):
            return .failure(error)
        }
    }

    private func buildCreateRequest(forQuery query: ResourceURLRepresentable,
                                    withData resourceData: Data) -> Result<URLRequest, SyncError> {
        guard let resourceUrl = query.resourceURL(relativeTo: self.configuration.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "POST"
        request.httpBody = resourceData

        for (header, value) in self.configuration.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return .success(request)
    }

    private func buildSaveRequest(forQuery query: ResourceURLRepresentable,
                                  forResource resource: Pushable) -> Result<URLRequest, SyncError> {
        guard let resourceUrl = query.resourceURL(relativeTo: self.configuration.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "PATCH"

        for (header, value) in self.configuration.requestHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        return self.strategy.resourceData(for: resource).map { data in
            request.httpBody = data
            return request
        }
    }

    private func buildDeleteRequest(forQuery query: RawSingleResourceQuery) -> Result<URLRequest, SyncError> {
        guard let resourceUrl = query.resourceURL(relativeTo: self.configuration.baseURL) else {
            return .failure(.invalidResourceURL)
        }

        var request = URLRequest(url: resourceUrl)
        request.httpMethod = "DELETE"

        for (header, value) in self.configuration.requestHeaders {
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

    // TODO: move to NETWORK
    private func doNetworkRequest(_ request: URLRequest, expectsData: Bool = true) -> Future<NetworkResult, SyncError> {
        let promise = Promise<NetworkResult, SyncError>()

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
                // special handling for calendar endpoint which returns an array
                let resourceData: MarshalDictionary
                if let resourceDataArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [MarshalDictionary] {
                    resourceData = ["data": resourceDataArray]
                } else if let resourceDataObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? MarshalDictionary {
                    resourceData = resourceDataObject
                } else {
                    promise.failure(.api(.serialization(.invalidDocumentStructure)))
                    return
                }

                switch self.strategy.validateResourceData(resourceData) {
                case .success:
                    let result = NetworkResult(resourceData: resourceData, headers: urlResponse.allHeaderFields)
                    promise.success(result)
                case let .failure(error):
                    promise.failure(error)
                }
            } catch {
                promise.failure(.api(.serialization(.jsonSerialization(error))))
            }
        }

        task.resume()
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

            let includedResourceData = self.strategy.extractIncludedResourceData(from: object)
            let context = SynchronizationContext(coreDataContext: coreDataContext, strategy: strategy, includedResourceData: includedResourceData)
            let dataArray = try self.strategy.extractResourceData(from: object) as [ResourceData]

            for data in dataArray {
                let id = try data.value(for: context.strategy.resourceKeyAttribute) as String
                if var existingObject = existingObjects.first(where: { $0.id == id }) {
                    try existingObject.update(from: data, with: context)
                    if let index = existingObjects.index(of: existingObject) {
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

            let includedResourceData = self.strategy.extractIncludedResourceData(from: object)
            let context = SynchronizationContext(coreDataContext: coreDataContext, strategy: self.strategy, includedResourceData: includedResourceData)
            let data = try self.strategy.extractResourceData(from: object) as ResourceData

            let id = try data.value(for: self.strategy.resourceKeyAttribute) as String

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

    public func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                        withQuery query: MultipleResourcesQuery<Resource>,
                                        deleteNotExistingResources: Bool = true) -> Future<SyncMultipleResult, SyncError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<SyncMultipleResult, SyncError>()

        configuration.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let coreDataFetch = self.fetchCoreDataObjects(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
                return retry(ImmediateExecutionContext, times: 5, coolDown: DispatchTimeInterval.seconds(2)) {
                    return self.doNetworkRequest(request)
                }
            }

            coreDataFetch.zip(networkRequest).flatMap(ImmediateExecutionContext) { objects, networkResult in
                return self.mergeResources(object: networkResult.resourceData,
                                           withExistingObjects: objects,
                                           deleteNotExistingResources: deleteNotExistingResources,
                                           in: context).map { resources in
                    return MergeMultipleResult(resources: resources, headers: networkResult.headers)
                }
            }.inject(ImmediateExecutionContext) {
                return Result<Void, AnyError> {
                    return try context.save()
                }.mapError { error in
                    return .coreData(error.error)
                }
            }.map(ImmediateExecutionContext) { mergeResult in
                return SyncMultipleResult(objectIds: mergeResult.resources.map { $0.objectID }, headers: mergeResult.headers)
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }
        }

        return promise.future
    }

    public func syncResource<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                       withQuery query: SingleResourceQuery<Resource>) -> Future<SyncSingleResult, SyncError> where Resource: NSManagedObject & Pullable {
        let promise = Promise<SyncSingleResult, SyncError>()

        configuration.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let coreDataFetch = self.fetchCoreDataObject(withFetchRequest: fetchRequest, inContext: context)
            let networkRequest = self.buildGetRequest(forQuery: query).flatMap { request in
                return retry(ImmediateExecutionContext, times: 5, coolDown: DispatchTimeInterval.seconds(2)) {
                    return self.doNetworkRequest(request)
                }
            }

            coreDataFetch.zip(networkRequest).flatMap(ImmediateExecutionContext) { object, networkResult -> Future<MergeSingleResult<Resource>, SyncError> in
                return self.mergeResource(object: networkResult.resourceData,
                                          withExistingObject: object,
                                          in: context).map { resource in
                    return MergeSingleResult(resource: resource, headers: networkResult.headers)
                }
            }.inject(ImmediateExecutionContext) {
                return Result<Void, AnyError> {
                    return try context.save()
                }.mapError { error in
                    return .coreData(error.error)
                }
            }.map(ImmediateExecutionContext) { mergeResult in
                return SyncSingleResult(objectId: mergeResult.resource.objectID, headers: mergeResult.headers)
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }
        }

        return promise.future
    }

    // MARK: - creating

    @discardableResult public func createResource<Resource>(ofType resourceType: Resource.Type,
                                                            withData resourceData: Data) -> Future<SyncSingleResult, SyncError> where Resource: NSManagedObject & Pullable & Pushable {
        let query = RawMultipleResourcesQuery(type: Resource.type)
        let urlRequest = self.buildCreateRequest(forQuery: query, withData: resourceData)

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request)
        }

        let promise = Promise<SyncSingleResult, SyncError>()

        configuration.persistentContainer.performBackgroundTask { coreDataContext in
            coreDataContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            let context = SynchronizationContext(coreDataContext: coreDataContext, strategy: self.strategy, includedResourceData: [])

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
                return Result<Void, AnyError> {
                    return try coreDataContext.save()
                }.mapError { error in
                    return .coreData(error.error)
                }
            }.onComplete(ImmediateExecutionContext) { result in
                promise.complete(result)
            }

        }

        return promise.future
    }

    @discardableResult public func createResource(_ resource: Pushable) -> Future<Void, SyncError> {
        let resourceType = type(of: resource).type
        let query = RawMultipleResourcesQuery(type: resourceType)
        let urlRequest = self.buildCreateRequest(forQuery: query, forResource: resource)

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.asVoid()
    }

    // MARK: - saving

    @discardableResult public func saveResource(_ resource: Pullable & Pushable) -> Future<Void, SyncError> {
        let resourceType = type(of: resource).type
        let query = RawSingleResourceQuery(type: resourceType, id: resource.id)
        let urlRequest = self.buildSaveRequest(forQuery: query, forResource: resource)

        let networkRequest = urlRequest.flatMap { request in
            return self.doNetworkRequest(request)
        }

        return networkRequest.asVoid()
    }

    // MARK: - deleting

    @discardableResult public func deleteResource(_ resource: Pushable & Pullable) -> Future<Void, SyncError> {
        let resourceType = type(of: resource).type
        let query = RawSingleResourceQuery(type: resourceType, id: resource.id)
        let networkRequest = self.buildDeleteRequest(forQuery: query).flatMap { request in
            return self.doNetworkRequest(request, expectsData: false)
        }

        return networkRequest.asVoid()
    }

}
