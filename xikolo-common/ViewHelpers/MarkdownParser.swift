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
        func fixFontStyle(inout fontStyle: [String: AnyObject]) {
            fontStyle[NSForegroundColorAttributeName] = UIColor.whiteColor()
        }
        func fixFontStyles(inout fontStyles: [[String: AnyObject]]) {
            for i in 0..<fontStyles.count {
                fixFontStyle(&fontStyles[i])
            }
        }

        if parser.defaultAttributes != nil {
            fixFontStyle(&parser.defaultAttributes!)
        }
        fixFontStyles(&parser.headerAttributes)
        fixFontStyles(&parser.listAttributes)
        fixFontStyles(&parser.quoteAttributes)
        fixFontStyle(&parser.linkAttributes)
        fixFontStyle(&parser.monospaceAttributes)
        fixFontStyle(&parser.strongAttributes)
        fixFontStyle(&parser.emphasisAttributes)
#endif

        return parser.attributedStringFromMarkdown(markdown)
    }

}
