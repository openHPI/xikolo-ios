//
//  MarkdownHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.12.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Down

class MarkdownHelper {

    class func parse(_ string: String) throws -> NSMutableAttributedString {
        let parser = Down(markdownString: string)

        #if os(tvOS)
            let color = "white"
            let fontSize = 29
        #else
            let color = "black"
            let fontSize = 14
        #endif

        if let attributedString = try? parser.toAttributedStringWithFont(font: "-apple-system", fontSize: fontSize, color: color) {
            let mutableString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            return mutableString
        } else {
            throw XikoloError.markdownError
        }
    }

}

public extension DownAttributedStringRenderable {
    public func toAttributedStringWithFont(_ options: DownOptions = .Default, font: String, fontSize: Int, color: String) throws -> NSAttributedString {
        let htmlResponse = try self.toHTML(options)
        let html = "<span style=\"font-family: \(font); font-size: \(fontSize); color: \(color);\">\(htmlResponse)</span>"
        let mutableString = try NSMutableAttributedString(data: html.data(using: .utf8)!, options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ], documentAttributes: nil)
        return mutableString.trimmedAttributedString(set: .whitespacesAndNewlines)
    }
}
