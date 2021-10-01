//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

public protocol SafeCastable {

    func require<T>(toHaveType type: T.Type,
                    hint hintExpression: @autoclosure () -> String?,
                    file: StaticString,
                    line: UInt) -> T

}

extension SafeCastable {

    public func require<T>(toHaveType type: T.Type,
                           hint hintExpression: @autoclosure () -> String? = nil,
                           file: StaticString = #file,
                           line: UInt = #line) -> T {
        guard let unwrapped = self as? T else {
            var message = "Required value was not of type \(T.self) in \(file), at line \(line)"

            if let hint = hintExpression() {
                message.append(". Debugging hint: \(hint)")
            }

            logger.error("%@", message)

            let exception = NSException(
                name: .invalidArgumentException,
                reason: message,
                userInfo: nil
            )
            exception.raise()

            fatalError(message)
        }

        return unwrapped
    }

}
