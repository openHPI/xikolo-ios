//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

#if os(iOS)

import UIKit

public enum NetworkIndicator {

    private static let queue = DispatchQueue(label: "de.xikolo.queue.network-indicator")
    private(set) static var counter = 0

    public static func start() {
        if #available(iOS 13, *) {} else {
            self.queue.sync {
                self.counter += 1
                self.update()
            }
        }
    }

    public static func end() {
        if #available(iOS 13, *) {} else {
            self.queue.sync {
                self.counter = max(self.counter - 1, 0)
                self.update()
            }
        }
    }

    /// Starting with iOS 13, `isNetworkActivityIndicatorVisible` is deprecated
    @available(iOS, obsoleted: 13.0)
    private static func update() {
        DispatchQueue.main.asyncAfter(deadline: 250.milliseconds.fromNow) {  // to avoid a flickering network indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = counter > 0
        }
    }

}

#endif
