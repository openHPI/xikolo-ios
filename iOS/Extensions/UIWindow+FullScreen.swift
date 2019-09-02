//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIWindow {

    var isFullScreen: Bool {
        return self.frame == self.screen.bounds
    }

}
