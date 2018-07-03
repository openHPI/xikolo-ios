//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import Foundation

class SyncHelper: SyncEngineDelegate {

    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

    func networkActivityStarted() {
        NetworkIndicator.start()
    }

    func networkActivityEnded() {
        NetworkIndicator.end()
    }

    func didSynchronizeResource(ofType resourceType: String, withResult result: SyncEngine.SyncSingleResult) {
        log.info("Successfully merged resource of type: \(resourceType)")
        self.handleSyncSuccess(result)
    }

    func didFailToSynchronizeResource(ofType resourceType: String, withError error: XikoloError) {
        CrashlyticsHelper.shared.recordAPIError(error)
        log.error("Failed to sync resource of type: \(resourceType) ==> \(error)")
        self.handleSyncFailure(error)
    }

    func didSynchronizeResources(ofType resourceType: String, withResult result: SyncEngine.SyncMultipleResult) {
        log.info("Successfully merged resources of type: \(resourceType)")
        self.handleSyncSuccess(result)
    }

    func didFailToSynchronizeResources(ofType resourceType: String, withError error: XikoloError) {
        CrashlyticsHelper.shared.recordAPIError(error)
        log.error("Failed to sync resources of type: \(resourceType) ==> \(error)")
        self.handleSyncFailure(error)
    }

    func didCreateResource(ofType resourceType: String) {
        log.info("Successfully created resource of type: \(resourceType)")
    }

    func didFailToCreateResource(ofType resourceType: String, withError error: XikoloError) {
        CrashlyticsHelper.shared.recordAPIError(error)
        log.error("Failed to create resource of type: \(resourceType) ==> \(error)")
    }

    func didSaveResource(ofType resourceType: String) {
        log.info("Successfully saved resource of type: \(resourceType)")
    }

    func didFailToSaveResource(ofType resourceType: String, withError error: XikoloError) {
        CrashlyticsHelper.shared.recordAPIError(error)
        log.error("Failed to save resource of type: \(resourceType) ==> \(error)")
    }

    func didDeleteResource(ofType resourceType: String) {
        log.info("Successfully deleted resource of type: \(resourceType)")
    }

    func didFailToDeleteResource(ofType resourceType: String, withError error: XikoloError) {
        CrashlyticsHelper.shared.recordAPIError(error)
        log.error("Failed to delete resource of type: \(resourceType) ==> \(error)")
    }

    private func handleSyncSuccess(_ syncResult: SyncEngine.SyncSingleResult) {
        self.checkForAPIDeprecation(syncResult.headers)
    }

    private func handleSyncSuccess(_ syncResult: SyncEngine.SyncMultipleResult) {
        self.checkForAPIDeprecation(syncResult.headers)
    }

    private func handleSyncFailure(_ error: XikoloError) {
        guard case let .api(.responseError(statusCode: statusCode, headers: headers)) = error else { return }
        DispatchQueue.main.async {
            guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }

            if 200 ... 299 ~= statusCode {
                self.checkForAPIDeprecation(headers)
            } else if statusCode == 406 {
                 tabBarController.state = .expired
            } else if statusCode == 503 {
                tabBarController.state = .maintenance
            }
        }
    }

    private func checkForAPIDeprecation(_ headers: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }

            guard let expirationDateString = headers[Routes.Header.apiVersionExpirationDate] as? String,
                  let expirationDate = SyncHelper.dateFormatter.date(from: expirationDateString),
                  expirationDate <= Date().subtractingTimeInterval(14.days) else {
                tabBarController.state = .standard
                return
            }

            tabBarController.state = .deprecated(expiresOn: expirationDate)
        }
    }

}
