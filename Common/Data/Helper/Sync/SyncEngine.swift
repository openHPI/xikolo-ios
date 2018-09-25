//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import SyncEngine

struct XikoloSyncConfig: SyncConfig {

    var baseURL: URL = Routes.api

    var requestHeaders: [String: String] = [
        Routes.Header.acceptKey: Routes.Header.acceptValue,
        Routes.Header.authKey: Routes.Header.authValuePrefix + UserProfileHelper.shared.userToken,
        Routes.Header.userPlatformKey: Routes.Header.userPlatformValue,
    ]

    var persistentContainer: NSPersistentContainer {
        return CoreDataHelper.persistentContainer
    }

}

extension SyncEngine {

    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

    public static func syncResourceXikolo<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                                    withQuery query: SingleResourceQuery<Resource>) -> Future<SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        let result = self.syncResource(withFetchRequest: fetchRequest,
                                       withQuery: query,
                                       withConfiguration: XikoloSyncConfig(),
                                       withStrategy: JsonAPISyncStrategy())

        return result.mapError { error -> XikoloError in
            return .synchronization(error)
        }.onSuccess { syncResult in
            log.info("Successfully merged resource of type: \(Resource.type)")
            self.handleSyncSuccess(syncResult)
        }.onFailure { error in
            log.error("Failed to sync resource of type: \(Resource.type) ==> \(error)")
            self.handleSyncFailure(error)
        }

    }

    public static func syncResourcesXikolo<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                                     withQuery query: MultipleResourcesQuery<Resource>,
                                                     deleteNotExistingResources: Bool = true) -> Future<SyncMultipleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        let result = self.syncResources(withFetchRequest: fetchRequest,
                                        withQuery: query,
                                        withConfiguration: XikoloSyncConfig(),
                                        withStrategy: JsonAPISyncStrategy(),
                                        deleteNotExistingResources: deleteNotExistingResources)

        return result.mapError { error -> XikoloError in
            return .synchronization(error)
        }.onSuccess { syncResult in
            log.info("Successfully merged resources of type: \(Resource.type)")
            self.handleSyncSuccess(syncResult)
        }.onFailure { error in
            log.error("Failed to sync resources of type: \(Resource.type) ==> \(error)")
            self.handleSyncFailure(error)
        }

    }

    @discardableResult public static func createResourceXikolo<Resource>(ofType resourceType: Resource.Type,
                                                                         withData resourceData: Data) -> Future<SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable & Pushable {
        return self.createResource(ofType: resourceType,
                                   withData: resourceData,
                                   withConfiguration: XikoloSyncConfig(),
                                   withStrategy: JsonAPISyncStrategy()).mapError { error -> XikoloError in
            return .synchronization(error)
        }.onSuccess { _ in
            log.info("Successfully created resource of type: \(resourceType)")
        }.onFailure { error in
            log.error("Failed to create resource of type: \(resourceType) ==> \(error)")
        }

    }

    @discardableResult public static func createResourceXikolo(_ resource: Pushable) -> Future<Void, XikoloError> {
        return self.createResource(resource,
                                   withConfiguration: XikoloSyncConfig(),
                                   withStrategy: JsonAPISyncStrategy()).mapError { error -> XikoloError in
            return .synchronization(error)
        }.onSuccess { _ in
            log.info("Successfully created resource of type: \(type(of: resource).type)")
        }.onFailure { error in
            log.error("Failed to create resource of type: \(resource) ==> \(error)")
        }
    }

    @discardableResult public static func saveResourceXikolo(_ resource: Pullable & Pushable) -> Future<Void, XikoloError> {
        return self.saveResource(resource,
                                 withConfiguration: XikoloSyncConfig(),
                                 withStrategy: JsonAPISyncStrategy()).mapError { error -> XikoloError in
            return .synchronization(error)
        }.onSuccess { _ in
            log.info("Successfully saved resource of type: \(type(of: resource).type)")
        }.onFailure { error in
            log.error("Failed to save resource of type: \(resource) ==> \(error)")
        }

    }

    @discardableResult public static func deleteResourceXikolo(_ resource: Pushable & Pullable) -> Future<Void, XikoloError> {
        return self.deleteResource(resource,
                                 withConfiguration: XikoloSyncConfig(),
                                 withStrategy: JsonAPISyncStrategy()).mapError { error -> XikoloError in
            return .synchronization(error)
        }.onSuccess { _ in
            log.info("Successfully deleted resource of type: \(type(of: resource).type)")
        }.onFailure { error in
            log.error("Failed to delete resource: \(resource) ==> \(error)")
        }

    }

    private static func handleSyncSuccess(_ syncResult: SyncEngine.SyncSingleResult) {
        self.checkForAPIDeprecation(syncResult.headers)
    }

    private static func handleSyncSuccess(_ syncResult: SyncEngine.SyncMultipleResult) {
        self.checkForAPIDeprecation(syncResult.headers)
    }

    private static func handleSyncFailure(_ error: XikoloError) {
        guard case let .synchronization(.api(.response(statusCode: statusCode, headers: headers))) = error else { return }
        // XXX
//        DispatchQueue.main.async {
//            guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }
//
//            if 200 ... 299 ~= statusCode {
//                self.checkForAPIDeprecation(headers)
//            } else if statusCode == 406 {
//                 tabBarController.state = .expired
//            } else if statusCode == 503 {
//                tabBarController.state = .maintenance
//            }
//        }
    }

    private static func checkForAPIDeprecation(_ headers: [AnyHashable: Any]) {

//        DispatchQueue.main.async {
//            guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }
//
//            guard let expirationDateString = headers[Routes.Header.apiVersionExpirationDate] as? String,
//                  let expirationDate = SyncEngine.dateFormatter.date(from: expirationDateString),
//                  expirationDate <= Date().subtractingTimeInterval(14.days) else {
//                tabBarController.state = .standard
//                return
//            }
//
//            tabBarController.state = .deprecated(expiresOn: expirationDate)
//        }
    }

}
