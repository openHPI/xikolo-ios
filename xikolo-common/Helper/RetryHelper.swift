//
//  PromiseRetryHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 11.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures

class RetryHelper {

    static let MaxDelay = 300

    enum Priority {
        case background
        case normal
        case ui
    }

    /*class func start( block: Promise -> Void, max maxRetries: Int, timesWithDelayOf delay: Int) {
        //let promise
        //recoverWi
        block.future.onSuccess {
            return promise.success()
        }.onFailure { error in
            guard maxRetries > 0 else { return promise.failure() }
            start(block(), max: --maxRetries, timesWithDelayOf: min(MaxDelay, delay))
        }
        //DispatchQueue.global().asyncAf
    }*/

    class func retry(times: Int, block: @escaping () -> Future<[Enrollment], XikoloError>) -> Future<[Enrollment], XikoloError> {
        return self.retry(times: times, cooldown: 30, block: block)
    }

    class func retry(times: Int, cooldown: TimeInterval, block: @escaping () -> Future<[Enrollment], XikoloError>, cooldownRate: @escaping (TimeInterval) -> TimeInterval = { rate in return rate }) -> Future<[Enrollment], XikoloError> {
        let future = block()

        if times-1 > 0 {
            return future.recoverWith { error in
                let nextCooldown = cooldownRate(cooldown)
                return self.after(interval: cooldown).flatMap { _ -> Future<[Enrollment], XikoloError> in
                    let ablock = block
                    return self.retry(times: times-1, cooldown: nextCooldown, block: ablock, cooldownRate: cooldownRate)
                }
            }
        }

        return future
    }

    class func after(interval: TimeInterval) -> Future<Void, XikoloError > {
        return Future { complete in
            let when = DispatchTime.now() + interval
            DispatchQueue.global().asyncAfter(deadline: when) {
                complete(.success())
            }
        }
    }

}
