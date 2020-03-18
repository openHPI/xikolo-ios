//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//
//  Based on the work of https://github.com/Cocoanetics/Swift-Examples/tree/master/Attachments
//

import UIKit

extension NSLayoutManager {

    /// Determine the character ranges for an attachment
    private func rangesForAttachment(attachment: NSTextAttachment) -> [NSRange] {
        guard let textStorage = self.textStorage else {
            return []
        }

        // find character range for this attachment
        let range = NSRange(location: 0, length: textStorage.length)

        var refreshRanges: [NSRange] = []

        textStorage.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, effectiveRange, nil) in
            guard let foundAttachment = value as? NSTextAttachment, foundAttachment == attachment else {
                return
            }

            // add this range to the refresh ranges
            refreshRanges.append(effectiveRange)
        }

        return refreshRanges
    }

    /// Trigger a relayout for an attachment
    func setNeedsLayout(forAttachment attachment: NSTextAttachment) {
        // invalidate the display for the corresponding ranges
        for range in self.rangesForAttachment(attachment: attachment).reversed() {
            // orig version
//            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
//            self.invalidateDisplay(forCharacterRange: range)

            // attempt 1
//            var actualRange = range
//            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: &actualRange)
//            self.invalidateDisplay(forCharacterRange: actualRange)
//
//            // attempt 2
//            var actualRange = range
//            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: &actualRange)
//            self.ensureLayout(forCharacterRange: actualRange)
//
//            // attempt 3
//            self.ensureLayout(forCharacterRange: range)

            var actualRange = range
            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: &actualRange)
            self.invalidateDisplay(forCharacterRange: range)
//            self.ensureLayout(forCharacterRange: actualRange)

        }
    }

    /// Trigger a re-display for an attachment
    func setNeedsDisplay(forAttachment attachment: NSTextAttachment) {
        // invalidate the display for the corresponding ranges
        for range in self.rangesForAttachment(attachment: attachment).reversed() {
            self.invalidateDisplay(forCharacterRange: range)
        }
    }
}
