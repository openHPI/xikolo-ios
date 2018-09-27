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

    public let networker = XikoloNetworker()

    public let baseURL: URL = Routes.api

    public var requestHeaders: [String: String] {
        return NetworkHelper.requestHeaders(for: self.baseURL)
    }

    public var persistentContainer: NSPersistentContainer {
        return CoreDataHelper.persistentContainer
    }

    public init() {}

    public func convertSyncError(_ error: SyncError) -> XikoloError {
        return XikoloError.synchronization(error)
    }

    // -

    public func didSucceedOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withResult result: SyncEngineResult) {
        log.info("Successfully performed operation (\(operationType)) for resource type: \(resourceType)")
        self.checkAPIStatus(statusCode: 200, headers: result.headers)
    }

    public func didFailOperation(_ operationType: SyncEngineOperation, forResourceType resourceType: String, withError error: XikoloError) {
        ErrorManager.shared.reportAPIError(error)
        log.error("Failed to perform operation (\(operationType)) for resource type: \(resourceType) ==> \(error)")

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
            expirationDate <= Date().subtractingTimeInterval(14.days) {
            status = .deprecated(expiresOn: expirationDate)
        } else {
            status = .standard
        }

        NotificationCenter.default.post(name: APIStatus.didChangeNotification, object: nil, userInfo: [APIStatusNotificationKey.status: status])
    }

}
