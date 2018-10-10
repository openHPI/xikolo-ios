//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

#if os(iOS)

import UIKit

public class NetworkIndicator {

    private static let queue = DispatchQueue(label: "de.xikolo.queue.network-indicator")
    private (set) static var counter = 0

    public class func start() {
        self.queue.sync {
            self.counter += 1
            self.update()
        }
    }

    public class func end() {
        self.queue.sync {
            self.counter = max(self.counter - 1, 0)
            self.update()
        }
    }

    private class func update() {
        DispatchQueue.main.asyncAfter(deadline: 250.milliseconds.fromNow) {  // to avoid a flickering network indicator
            UIApplication.shared.isNetworkActivityIndicatorVisible = counter > 0
        }
    }

}

#endif
