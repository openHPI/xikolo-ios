//
//  SyncHelper.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.01.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import Foundation
import BrightFutures
import CoreData

struct SyncHelper {

    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return formatter
    }()

    @discardableResult static func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                        withQuery query: MultipleResourcesQuery<Resource>,
                                        deleteNotExistingResources: Bool = true) -> Future<SyncEngine.SyncMultipleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: deleteNotExistingResources).onSuccess { syncResult in
            print("Verbose: Successfully merged resources of type: \(Resource.type)")
            SyncHelper.handleSyncSuccess(syncResult)
        }.onFailure { error in
            print("Error: Failed to sync resources of type: \(Resource.type) ==> \(error)")
            SyncHelper.handleSyncFailure(error)
        }
    }

    @discardableResult static func syncResource<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                       withQuery query: SingleResourceQuery<Resource>) -> Future<SyncEngine.SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query).onSuccess { syncResult in
            print("Verbose: Successfully merged resource of type: \(Resource.type)")
            SyncHelper.handleSyncSuccess(syncResult)
        }.onFailure { error in
            print("Error: Failed to sync resource of type: \(Resource.type) ==> \(error)")
            SyncHelper.handleSyncFailure(error)
        }
    }

    @discardableResult static func saveResource(_ resource: Pushable) -> Future<Void, XikoloError> {
        return SyncEngine.saveResource(resource).onSuccess { _ in
            print("Verbose: Successfully saved resource of type: \(type(of: resource).type)")
        }.onFailure { error in
            print("Error: Failed to save resource of type: \(resource) ==> \(error)")
        }
    }

    @discardableResult static func saveResource(_ resource: Pushable & Pullable) -> Future<Void, XikoloError> {
        return SyncEngine.saveResource(resource).onSuccess { _ in
            print("Verbose: Successfully saved resource of type: \(type(of: resource).type)")
        }.onFailure { error in
            print("Error: Failed to save resource of type: \(resource) ==> \(error)")
        }
    }

    @discardableResult static func deleteResource(_ resource: Pushable & Pullable) -> Future<Void, XikoloError> {
        return SyncEngine.deleteResource(resource).onSuccess { _ in
            print("Verbose: Successfully deleted resource of type: \(type(of: resource).type)")
        }.onFailure { error in
            print("Error: Failed to delete resource: \(resource) ==> \(error)")
        }
    }

}

extension SyncHelper {

    private static func handleSyncSuccess(_ syncResult: SyncEngine.SyncSingleResult) {
        self.checkForAPIDeprecation(syncResult.headers)
    }

    private static func handleSyncSuccess(_ syncResult: SyncEngine.SyncMultipleResult) {
        self.checkForAPIDeprecation(syncResult.headers)
    }

    private static func handleSyncFailure(_ error: XikoloError) {
        guard case let .api(.responseError(statusCode: statusCode, headers: headers)) = error else { return }
        DispatchQueue.main.async {
            guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }

            if 200 ... 299 ~= statusCode {
                self.checkForAPIDeprecation(headers)
            } else if statusCode == 406 {
                 tabBarController.updateState(.expired)
            } else if statusCode == 503 {
                tabBarController.updateState(.maintenance)
            }
        }
    }

    private static func checkForAPIDeprecation(_ headers: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }

            guard let expirationDateString = headers[Routes.HTTP_API_Version_Expiration_Date_Header] as? String,
                  let expirationDate = SyncHelper.dateFormatter.date(from: expirationDateString),
                  expirationDate <= Date().subtractingTimeInterval(14.days) else {
                tabBarController.updateState(.standard)
                return
            }

            tabBarController.updateState(.deprecated(expiresOn: expirationDate))
        }
    }

}
