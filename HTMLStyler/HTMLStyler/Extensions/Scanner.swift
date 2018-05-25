//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Scanner {

    // Returns a string, scanned as long as characters from a given character set are encountered, or `nil` if none are found.
    func scanCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanCharacters(from: set, into: &value) {
            return value as String?
        }
        return nil
    }

    // Returns a string, scanned until a character from a given character set are encountered, or the remainder of the scanner's string.
    // Returns `nil` if the scanner is already `atEnd`.
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanUpToCharacters(from: set, into: &value) {
            return value as String?
        }
        return nil
    }

    // Returns the given string if scanned, or `nil` if not found.
    @discardableResult func scanString(_ str: String) -> String? {
        var value: NSString? = ""
        if scanString(str, into: &value) {
            return value as String?
        }
        return nil
    }

    // Returns a string, scanned until the given string is found, or the remainder of the scanner's string.
    // Returns `nil` if the scanner is already `atEnd`.
    func scanUpTo(_ str: String) -> String? {
        var value: NSString? = ""
        if scanUpTo(str, into: &value) {
            return value as String?
        }
        return nil
    }

}
