//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {

    // Credit goes to https://stackoverflow.com/a/41300031/7414898
    func trimmedAttributedString(set: CharacterSet) -> NSMutableAttributedString {
        let invertedSet = set.inverted

        var range = (string as NSString).rangeOfCharacter(from: invertedSet)
        let loc = range.length > 0 ? range.location : 0

        range = (string as NSString).rangeOfCharacter(from: invertedSet, options: .backwards)
        let len = (range.length > 0 ? NSMaxRange(range) : string.count) - loc

        let r = self.attributedSubstring(from: NSRange(location: loc, length: len))
        return NSMutableAttributedString(attributedString: r)
    }

}
