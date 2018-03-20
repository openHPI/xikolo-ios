//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

class Content: NSManagedObject {

    var isAvailableOffline: Bool {
        return false
    }

}

extension Content: AbstractPullable {}
