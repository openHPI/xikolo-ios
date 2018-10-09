//
//  Created for xikolo-ios under MIT license.
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
            onComplete(ImmediateExecutionContext) { result in
                queue.asyncAfter(deadline: time) {
                    complete(result)
                }
            }
        }
    }

}
