//
//  MarkdownParser.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 09.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import TSMarkdownParser

class MarkdownParser {

    class func parse(markdown: String) -> NSAttributedString {
        let parser = TSMarkdownParser.standardParser()

        parser.addShortHeaderParsingWithMaxLevel(0, leadFormattingBlock: { attributedString, range, level in
            attributedString.deleteCharactersInRange(range)
        }, textFormattingBlock: { [unowned parser] attributedString, range, level in
            let attributes = Int(level) < parser.headerAttributes.count ? parser.headerAttributes[Int(level)] : parser.headerAttributes.last!
            attributedString.addAttributes(attributes, range:range)
        })

#if os(tvOS)
        parser.defaultAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(29),
        ]

        let headerSizes: [CGFloat] = [76, 57, 48, 40, 36, 32]
        parser.headerAttributes = headerSizes.map { size in
            return [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.systemFontOfSize(size),
            ]
        }
#endif

        return parser.attributedStringFromMarkdown(markdown)
    }

}
