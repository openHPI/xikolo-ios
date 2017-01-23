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

    class func parse(_ markdown: String) -> NSAttributedString {
        let parser = MarkdownParser()
        return parser.parse(markdown)
    }

    let parser: TSMarkdownParser

    required init() {
        parser = TSMarkdownParser.standard()

        parser.addShortHeaderParsing(withMaxLevel: 0, leadFormattingBlock: { attributedString, range, level in
            attributedString.deleteCharacters(in: range)
        }, textFormattingBlock: { [unowned parser] attributedString, range, level in
            let level = Int(level)
            let attributes = level < parser.headerAttributes.count ? parser.headerAttributes[level] : parser.headerAttributes.last!
            attributedString.addAttributes(attributes, range:range)
        })
    }

    func setColor(_ color: UIColor) {
        setFontStyle(NSForegroundColorAttributeName, value: color)
    }

    internal func setFontStyle(_ key: String, value: AnyObject) {
        if parser.defaultAttributes != nil {
            overrideFontStyle(&parser.defaultAttributes!, key: key, value: value)
        }
        overrideFontStyles(&parser.headerAttributes, key: key, value: value)
        overrideFontStyles(&parser.listAttributes, key: key, value: value)
        overrideFontStyles(&parser.quoteAttributes, key: key, value: value)
        overrideFontStyle(&parser.linkAttributes, key: key, value: value)
        overrideFontStyle(&parser.monospaceAttributes, key: key, value: value)
        overrideFontStyle(&parser.strongAttributes, key: key, value: value)
        overrideFontStyle(&parser.emphasisAttributes, key: key, value: value)
    }

    internal func overrideFontStyles(_ fontStyles: inout [[String: Any]], key: String, value: AnyObject) {
        for i in 0..<fontStyles.count {
            overrideFontStyle(&fontStyles[i], key: key, value: value)
        }
    }

    internal func overrideFontStyle(_ fontStyle: inout [String: Any], key: String, value: AnyObject) {
        fontStyle[key] = value
    }

    func parse(_ markdown: String) -> NSAttributedString {

        return parser.attributedString(fromMarkdown: markdown)
    }

}
