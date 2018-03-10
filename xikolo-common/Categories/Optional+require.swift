//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Optional {

    func require(hint hintExpression: @autoclosure () -> String? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> Wrapped {
        guard let unwrapped = self else {
            var message = "Required value was nil in \(file), at line \(line)"

            if let hint = hintExpression() {
                message.append(". Debugging hint: \(hint)")
            }

            log.severe(message)

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
