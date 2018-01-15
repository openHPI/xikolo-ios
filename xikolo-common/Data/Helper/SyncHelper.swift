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

    static func syncResources<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                        withQuery query: MultipleResourcesQuery<Resource>,
                                        deleteNotExistingResources: Bool = true) -> Future<SyncEngine.SyncMultipleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: deleteNotExistingResources).onSuccess { syncResult in
            SyncHelper.handleSyncSuccess(syncResult)
        }.onFailure { error in
            SyncHelper.handleSyncFailure(error)
        }
    }

    static func syncResource<Resource>(withFetchRequest fetchRequest: NSFetchRequest<Resource>,
                                       withQuery query: SingleResourceQuery<Resource>) -> Future<SyncEngine.SyncSingleResult, XikoloError> where Resource: NSManagedObject & Pullable {
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query).onSuccess { syncResult in
            SyncHelper.handleSyncSuccess(syncResult)
        }.onFailure { error in
            SyncHelper.handleSyncFailure(error)
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
        guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }

        if 200 ... 299 ~= statusCode {
            self.checkForAPIDeprecation(headers)
        } else if statusCode == 406 {
             tabBarController.updateStatus(.expired)
        } else if statusCode == 503 {
            tabBarController.updateStatus(.maintainance)
        }
    }

    private static func checkForAPIDeprecation(_ headers: [AnyHashable: Any]) {
        guard let tabBarController = AppDelegate.instance().tabBarController as? XikoloTabBarController else { return }

        guard let expirationDateString = headers[Routes.HTTP_API_Version_Expiration_Date_Header] as? String,
              let expirationDate = SyncHelper.dateFormatter.date(from: expirationDateString),
              expirationDate <= Date().subtractingTimeInterval(14.days) else {
            tabBarController.updateStatus(.standard)
            return
        }

        tabBarController.updateStatus(.deprecated(expiresOn: expirationDate))
    }

}
