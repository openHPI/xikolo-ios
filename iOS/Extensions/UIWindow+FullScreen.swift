//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIWindow {

    var frameIsFullScreen: Bool {
        return self.frame == self.screen.bounds
    }

    func isFullScreen(withSize size: CGSize) -> Bool {
        return self.screen.bounds.size == size
    }

}
