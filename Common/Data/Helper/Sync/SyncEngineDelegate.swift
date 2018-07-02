//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol SyncEngineDelegate {

    func didSynchronizeResource(ofType resourceType: String, withResult result: SyncEngine.SyncSingleResult)
    func didFailToSynchronizeResource(ofType resourceType: String, withError error: XikoloError)

    func didSynchronizeResources(ofType resourceType: String, withResult result: SyncEngine.SyncMultipleResult)
    func didFailToSynchronizeResources(ofType resourceType: String, withError error: XikoloError)

    func didCreateResource(ofType resourceType: String)
    func didFailToCreateResource(ofType resourceType: String, withError error: XikoloError)

    func didSaveResource(ofType resourceType: String)
    func didFailToSaveResource(ofType resourceType: String, withError error: XikoloError)

    func didDeleteResource(ofType resourceType: String)
    func didFailToDeleteResource(ofType resourceType: String, withError error: XikoloError)

}
