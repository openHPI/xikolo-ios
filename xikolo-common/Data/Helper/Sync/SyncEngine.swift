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
import CoreData
import Marshal

struct SyncEngine {

    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 300
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }()

    // MARK: - build url request

    private static func buildGetRequest<Query>(forQuery query: Query) -> Result<URLRequest, XikoloError> where Query: ResourceQuery {
        guard let baseURL = URL(string: Routes.API_V2_URL) else {
            return .failure(.invalidURL(Routes.API_V2_URL))
        }

        guard let resourceUrl = query.resourceURL(relativeTo: baseURL) else {
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

        guard let baseURL = URL(string: Routes.API_V2_URL) else {
            return .failure(.invalidURL(Routes.API_V2_URL))
        }

        guard let resourceUrl = query.resourceURL(relativeTo: baseURL) else {
            return .failure(.invalidResourceURL)
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

        guard let baseURL = URL(string: Routes.API_V2_URL) else {
            return .failure(.invalidURL(Routes.API_V2_URL))
        }

        guard let resourceUrl = query.resourceURL(relativeTo: baseURL) else {
            return .failure(.invalidResourceURL)
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

        let task = self.session.dataTask(with: request) { (data, response, error) in
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
