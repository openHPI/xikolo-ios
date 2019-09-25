//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension UserDefaults {

    private static let migrateCoreDataModelToCommonKey = "de.xikolo.ios.core-data.migrate-core-data-model-to-common"

    var didMigrateCoreDataModelToCommon: Bool {
        get {
            return self.bool(forKey: Self.migrateCoreDataModelToCommonKey)
        }
        set {
            self.set(newValue, forKey: Self.migrateCoreDataModelToCommonKey)
        }
    }

}
