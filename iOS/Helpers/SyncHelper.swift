//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable line_length

import BrightFutures
import Common
import CoreData
import Foundation

struct SyncHelper: SyncEngineDelegate {

    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

//    static func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
//                                        withQuery query: MultipleResourcesQuery<Resource>,
//                                        deleteNotExistingResources: Bool = true) -> Future<SyncEngine.SyncMultipleResult, XikoloError> where Resource: NSManagedObject & Pullable {
//        return SyncEngine.shared.syncResources(withFetchRequest: fetchRequest,
//                                               withQuery: query,
//                                               deleteNotExistingResources: deleteNotExistingResources).onSuccess { syncResult in
//            log.info("Successfully merged resources of type: \(Resource.type)")
//            SyncHelper.handleSyncSuccess(syncResult)
//        }.onFailure { error in
//            CrashlyticsHelper.shared.recordAPIError(error)
//            log.error("Failed to sync resources of type: \(Resource.type) ==> \(error)")
//            SyncHelper.handleSyncFailure(error)
//        }
//    }
//
//    static func syncResource<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
//                                       withQuery query: SingleResourceQuery<Resource>) -> Future<SyncEngine.SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable {
//        return SyncEngine.shared.syncResource(withFetchRequest: fetchRequest, withQuery: query).onSuccess { syncResult in
//            log.info("Successfully merged resource of type: \(Resource.type)")
//            SyncHelper.handleSyncSuccess(syncResult)
//        }.onFailure { error in
//            CrashlyticsHelper.shared.recordAPIError(error)
//            log.error("Failed to sync resource of type: \(Resource.type) ==> \(error)")
//            SyncHelper.handleSyncFailure(error)
//        }
//    }
//
//    @discardableResult static func createResource<Resource>(ofType resourceType: Resource.Type, withData resourceData: Data) -> Future<SyncEngine.SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable & Pushable {
//        return SyncEngine.shared.createResource(ofType: resourceType, withData: resourceData).onSuccess { _ in
//            log.info("Successfully created and saved resource of type: \(resourceType.type)")
//        }.onFailure { error in
//            CrashlyticsHelper.shared.recordAPIError(error)
//            log.error("Failed to create and save resource of type: \(resourceType) ==> \(error)")
//        }
//    }
//
//    @discardableResult static func createResource(_ resource: Pushable) -> Future<Void, XikoloError> {
//        return SyncEngine.shared.createResource(resource).onSuccess { _ in
//            log.info("Successfully created resource of type: \(type(of: resource).type)")
//        }.onFailure { error in
//            CrashlyticsHelper.shared.recordAPIError(error)
//            log.error("Failed to create resource of type: \(resource) ==> \(error)")
//        }
//    }
//
//    @discardableResult static func saveResource(_ resource: Pullable & Pushable) -> Future<Void, XikoloError> {
//        return SyncEngine.shared.saveResource(resource).onSuccess { _ in
//            log.info("Successfully saved resource of type: \(type(of: resource).type)")
//        }.onFailure { error in
//            CrashlyticsHelper.shared.recordAPIError(error)
//            log.error("Failed to save resource of type: \(resource) ==> \(error)")
//        }
//    }
//
//    @discardableResult static func deleteResource(_ resource: Pullable & Pushable) -> Future<Void, XikoloError> {
//        return SyncEngine.shared.deleteResource(resource).onSuccess { _ in
//            log.info("Successfully deleted resource of type: \(type(of: resource).type)")
//        }.onFailure { error in
//            CrashlyticsHelper.shared.recordAPIError(error)
//            log.error("Failed to delete resource: \(resource) ==> \(error)")
//        }
//    }
//
//}
//
//extension SyncHelper {

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
