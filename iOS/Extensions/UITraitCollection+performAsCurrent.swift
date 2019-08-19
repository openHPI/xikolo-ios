//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@available(iOS, obsoleted: 13.0)
extension UITraitCollection {

    func performAsCurrent(_ actions: () -> Void) {
        actions()
    }

}
