//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Stockpile

extension URLSessionConfiguration {

    public static var waitingDefault: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default

        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }

        return configuration
    }

    public static var nonExpensive: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default

        if #available(iOS 13, *) {
            configuration.allowsExpensiveNetworkAccess = false
        }

        return configuration
    }

}

public struct XikoloNetworker: SyncNetworker {

    let session: URLSession

    public init(sessionConfiguration: URLSessionConfiguration? = nil) {
        let sessionConfiguration = sessionConfiguration ?? .waitingDefault
        self.session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
    }

    public func perform(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = self.session.dataTask(with: request) { data, response, error in
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

    public static let persistentContainerQueue: OperationQueue = {
        let persistentContainerQueue = OperationQueue()
        persistentContainerQueue.maxConcurrentOperationCount = 1
        return persistentContainerQueue
    }()

    public let networker: XikoloNetworker

    public let baseURL: URL = Routes.api

    public var requestHeaders: [String: String] {
        return NetworkHelper.requestHeaders(for: self.baseURL, additionalHeaders: [
            Routes.Header.contentTypeKey: Routes.Header.contentTypeValueJSONAPI,
        ])
    }

    public var persistentContainer: NSPersistentContainer {
        return CoreDataHelper.persistentContainer
    }

    public let persistentContainerQueue: OperationQueue = {
        return Self.persistentContainerQueue
    }()

    public init(networker: XikoloNetworker = XikoloNetworker()) {
        self.networker = networker
    }

    public func convertSyncError(_ error: SyncError) -> XikoloError {
        return XikoloError.synchronization(error)
    }

    // -

    public func didSucceedOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withResult result: SyncEngineResult) {
        logger.info("Successfully performed operation (\(operationType)) for resource type: \(resourceType)")
        self.checkAPIStatus(statusCode: 200, headers: result.headers)
    }

    public func didFailOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withError error: XikoloError) {
        ErrorManager.shared.reportAPIError(error)
        logger.error("Failed to perform operation (\(operationType)) for resource type: \(resourceType) ==> \(error)")

        if case let .synchronization(.api(.response(statusCode: statusCode, headers: headers))) = error {
            self.checkAPIStatus(statusCode: statusCode, headers: headers)
        }

    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

    private func checkAPIStatus(statusCode: Int, headers: [AnyHashable: Any]) {
        let status: APIStatus

        if statusCode == 406 {
            status = .expired
        } else if statusCode == 503 {
            status = .maintenance
        } else if 200 ... 299 ~= statusCode,
            let expirationDateString = headers[Routes.Header.apiVersionExpirationDate] as? String,
            let expirationDate = self.dateFormatter.date(from: expirationDateString),
            let todayIn14days = Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            expirationDate <= todayIn14days {
            status = .deprecated(expiresOn: expirationDate)
        } else {
            status = .standard
        }

        NotificationCenter.default.post(name: APIStatus.didChangeNotification, object: nil, userInfo: [APIStatusNotificationKey.status: status])
    }

}
