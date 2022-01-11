//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Optional {

    public func require(hint hintExpression: @autoclosure () -> String? = nil,
                        file: StaticString = #file,
                        line: UInt = #line) -> Wrapped {
        guard let unwrapped = self else {
            var message = "Required value was nil in \(file), at line \(line)"

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
