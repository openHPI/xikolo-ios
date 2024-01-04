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
        configuration.waitsForConnectivity = true
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
            completionHandler(data, response, error)
        }

        task.resume()
    }

}

public class XikoloBackgroundNetworker: NSObject, SyncNetworker, URLSessionDownloadDelegate {

    public typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    let sessionConfiguration: URLSessionConfiguration
    var backgroundCompletionHandler: (() -> Void)
    var completionHandlers: [URLSessionTask: CompletionHandler] = [:]

    var session: URLSession!

    public init(withIdentifier identifier: String, saveBattery: Bool = false, backgroundCompletionHandler: @escaping (() -> Void)) {
        self.sessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)

        if saveBattery {
            self.sessionConfiguration.waitsForConnectivity = true
            if #available(iOS 13, *) {
                self.sessionConfiguration.allowsConstrainedNetworkAccess = false
                self.sessionConfiguration.allowsExpensiveNetworkAccess = false
            }
        }

        self.backgroundCompletionHandler = backgroundCompletionHandler
        super.init()
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }

    public func perform(request: URLRequest, completionHandler: @escaping CompletionHandler) {
        let task = self.session.downloadTask(with: request)
        self.completionHandlers[task] = completionHandler
        task.resume()
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let completionHandler = self.completionHandlers.removeValue(forKey: task)
        completionHandler?(nil, task.response, error)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let completionHandler = self.completionHandlers.removeValue(forKey: downloadTask)
        let data = try? Data(contentsOf: location)
        completionHandler?(data, downloadTask.response, downloadTask.error)
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.backgroundCompletionHandler()
    }

}

public struct XikoloSyncEngine: SyncEngine {

    public static let persistentContainerQueue: OperationQueue = {
        let persistentContainerQueue = OperationQueue()
        persistentContainerQueue.maxConcurrentOperationCount = 1
        return persistentContainerQueue
    }()

    public let networker: SyncNetworker

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

    public init(networker: SyncNetworker = XikoloNetworker()) {
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
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

    private func checkAPIStatus(statusCode: Int, headers: [AnyHashable: Any]) {
        let status: APIStatus

        if statusCode == 406 {
            status = .expired
        } else if 500 ... 504 ~= statusCode {
            status = .maintenance
        } else if 200 ... 299 ~= statusCode,
            let expirationDateString = headers[Routes.Header.apiVersionExpirationDate] as? String,
            let expirationDate = self.dateFormatter.date(from: expirationDateString),
            let todayIn1Month = Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            expirationDate < todayIn1Month {
            status = .deprecated(expiresOn: expirationDate)
        } else {
            status = .standard
        }

        NotificationCenter.default.post(name: APIStatus.didChangeNotification, object: nil, userInfo: [APIStatusNotificationKey.status: status])
    }

}
