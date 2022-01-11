//
//  Created for xikolo-ios under GPL-3.0 license.
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
