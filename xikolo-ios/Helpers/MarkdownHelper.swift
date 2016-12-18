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

    class func parse(string: String) throws -> NSMutableAttributedString {
        let parser = Down(markdownString: string)
        if let attributedString = try? parser.toAttributedString() {
            let mutableString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            /*let font = UIFont.systemFontOfSize(UIFont.systemFontSize())
            let attributes: [String : AnyObject] = [NSFontAttributeName : font]
            let range: NSRange = NSRange.init(location: 0, length: mutableString.length)
            mutableString.addAttributes(attributes, range: range)*/
            return mutableString
        } else {
            throw XikoloError.MarkdownError
        }
    }

}
