//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures

extension AsyncType {

    public func earliest(at time: DispatchTime) -> Self {
        let queue = Thread.isMainThread ? DispatchQueue.main : DispatchQueue.global()
        return earliest(queue, at: time)
    }

    public func earliest(_ queue: DispatchQueue, at time: DispatchTime) -> Self {
        return Self { complete in
            onComplete(immediateExecutionContext) { result in
                queue.asyncAfter(deadline: time) {
                    complete(result)
                }
            }
        }
    }

}
