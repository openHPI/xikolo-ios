//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

public protocol SyncConfig {
    // Requests
    var baseURL: URL { get }
    var requestHeaders: [String: String] { get }

    // Core Data
    var persistentContainer: NSPersistentContainer { get }

}
