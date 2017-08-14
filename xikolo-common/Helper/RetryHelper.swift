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

    class func start( block: Promise -> Void, max maxRetries: Int, timesWithDelayOf delay: Int) {
        //let promise
        //recoverWi
        block.future.onSuccess {
            return promise.success()
        }.onFailure { error in
            guard maxRetries > 0 else { return promise.failure() }
            start(block(), max: --maxRetries, timesWithDelayOf: min(MaxDelay, delay))
        }
        //DispatchQueue.global().asyncAf
    }

    func retry<T, E>(times: Int, block: @escaping () -> Future<T, E>) -> Future<T, E> {
        return retry(times: times, cooldown: 0, block: block)
    }

    func retry<T, E>(times: Int, cooldown: TimeInterval, block: @escaping () -> Future<T, E>, cooldownRate: @escaping (TimeInterval) -> TimeInterval = { rate in return rate }) -> Future<T, E> {
        let future = block()

        if times > 0 {
            return future.recoverWith { error in
                let nextCooldown = cooldownRate(cooldown)
                return after(interval: cooldown).flatMap { _ -> Future<T, E> in
                    let ablock = block
                    return retry(times: times-1, cooldown: nextCooldown, block: ablock, cooldownRate: cooldownRate)
                }
            }
        }

        return future
    }

    func after(interval: TimeInterval) -> Future<Void, NoError> {
        return Future { complete in
            let when = DispatchTime.now() + interval
            DispatchQueue.global().asyncAfter(deadline: when) {
                complete(.success())
            }
        }
    }

}
