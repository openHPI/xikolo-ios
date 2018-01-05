//
//  Optional+require.swift
//  xikolo-ios
//
//  Created by Max Bothe on 04.01.18.
//  Copyright © 2018 HPI. All rights reserved.
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

            fatalError(message)
        }

        return unwrapped
    }

}
