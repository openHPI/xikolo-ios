//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import SyncEngine

public struct XikoloNetworker: SyncNetworker {

    private var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 90
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }

        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }

    public func perform(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            #if os(iOS)
            NetworkIndicator.end()
            #endif

            completionHandler(data, response, error)
        }

        #if os(iOS)
        NetworkIndicator.start()
        #endif

        task.resume()
    }

}

public struct XikoloSyncEngine: SyncEngine {

    public let strategy = JsonAPISyncStrategy()
    public let networker = XikoloNetworker()

    public let baseURL: URL = Routes.api

    public var requestHeaders: [String: String] {
        return NetworkHelper.requestHeaders(for: self.baseURL)
    }

    public var persistentContainer: NSPersistentContainer {
        return CoreDataHelper.persistentContainer
    }

    public init() {}


    // -

    public func didSynchronizeResource(ofType resourceType: String, withResult result: SyncSingleResult) {
        log.info("Successfully merged resource of type: \(resourceType)")
        self.handleSyncSuccess(result)
    }

    public func didFailToSynchronizeResource(ofType resourceType: String, withError error: SyncError) {
        ErrorManager.shared.reportAPIError(error)
        log.error("Failed to sync resource of type: \(resourceType) ==> \(error)")
        self.handleSyncFailure(error)
    }

    public func didSynchronizeResources(ofType resourceType: String, withResult result: SyncMultipleResult) {
        log.info("Successfully merged resources of type: \(resourceType)")
        self.handleSyncSuccess(result)
    }

    public func didFailToSynchronizeResources(ofType resourceType: String, withError error: SyncError) {
        ErrorManager.shared.reportAPIError(error)
        log.error("Failed to sync resources of type: \(resourceType) ==> \(error)")
        self.handleSyncFailure(error)
    }

    public func didCreateResource(ofType resourceType: String) {
        log.info("Successfully created resource of type: \(resourceType)")
    }

    public func didFailToCreateResource(ofType resourceType: String, withError error: SyncError) {
        ErrorManager.shared.reportAPIError(error)
        log.error("Failed to create resource of type: \(resourceType) ==> \(error)")
    }

    public func didSaveResource(ofType resourceType: String) {
        log.info("Successfully saved resource of type: \(resourceType)")
    }

    public func didFailToSaveResource(ofType resourceType: String, withError error: SyncError) {
        ErrorManager.shared.reportAPIError(error)
        log.error("Failed to save resource of type: \(resourceType) ==> \(error)")
    }

    public func didDeleteResource(ofType resourceType: String) {
        log.info("Successfully deleted resource of type: \(resourceType)")
    }

    public func didFailToDeleteResource(ofType resourceType: String, withError error: SyncError) {
        ErrorManager.shared.reportAPIError(error)
        log.error("Failed to delete resource of type: \(resourceType) ==> \(error)")
    }

    private func handleSyncSuccess(_ syncResult: SyncSingleResult) {
        self.checkAPIStatus(statusCode: 200, headers: syncResult.headers)
    }

    private func handleSyncSuccess(_ syncResult: SyncMultipleResult) {
        self.checkAPIStatus(statusCode: 200, headers: syncResult.headers)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

    private func handleSyncFailure(_ error: SyncError) {
        guard case let .api(.response(statusCode: statusCode, headers: headers)) = error else { return }
        self.checkAPIStatus(statusCode: statusCode, headers: headers)
    }

    private func checkAPIStatus(statusCode: Int, headers: [AnyHashable: Any]) {
        let status: APIStatus

        if statusCode == 406 {
            status = .expired
        } else if statusCode == 503 {
            status = .maintenance
        } else if 200 ... 299 ~= statusCode,
            let expirationDateString = headers[Routes.Header.apiVersionExpirationDate] as? String,
            let expirationDate = self.dateFormatter.date(from: expirationDateString),
            expirationDate <= Date().subtractingTimeInterval(14.days) {
            status = .deprecated(expiresOn: expirationDate)
        } else {
            status = .standard
        }

        NotificationCenter.default.post(name: APIStatus.didChangeNotification, object: nil, userInfo: [APIStatusNotificationKey.status: status])
    }

}
