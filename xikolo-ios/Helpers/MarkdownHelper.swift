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
        if let attributedString = try? parser.toAttributedStringWithFont(font: "-apple-system", fontSize: "14") {
            let mutableString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            return mutableString
        } else {
            throw XikoloError.markdownError
        }
    }

}

public extension DownAttributedStringRenderable {
    public func toAttributedStringWithFont(_ options: DownOptions = .Default, font: String, fontSize: String) throws -> NSAttributedString {
        let htmlResponse = try self.toHTML(options)
        let html = "<span style=\"font-family: \(font); font-size: \(fontSize)\">\(htmlResponse)</span>"
        return try NSAttributedString(htmlString: html)
    }
}
