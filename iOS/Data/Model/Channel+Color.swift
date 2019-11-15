//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension Channel {

    var color: UIColor? {
        return self.colorString.flatMap(UIColor.init(hexString:))
    }

}
