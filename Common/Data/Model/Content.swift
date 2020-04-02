//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

public class Content: NSManagedObject {

    public var isAvailableOffline: Bool {
        return false
    }

}

extension Content: AbstractPullable {}
