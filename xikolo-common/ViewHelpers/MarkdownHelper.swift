//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Down

class MarkdownHelper {

    class func parse(_ string: String) throws -> NSMutableAttributedString {
        let parser = Down(markdownString: string)

        #if os(tvOS)
            let color = "white"
        #else
            let color = "black"
        #endif

        if let attributedString = try? parser.toAttributedStringWithFont(font: "-apple-system-body", color: color) {
            let mutableString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            return mutableString
        } else {
            throw XikoloError.markdownError
        }
    }

}

public extension DownAttributedStringRenderable {
    public func toAttributedStringWithFont(_ options: DownOptions = .Default, font: String, color: String) throws -> NSAttributedString {
        let htmlResponse = try self.toHTML(options)
        let html = "<span style=\"font: \(font); color: \(color);\">\(htmlResponse)</span>"
        let mutableString = try NSMutableAttributedString(data: html.data(using: .utf8)!, options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ], documentAttributes: nil)
        return mutableString.trimmedAttributedString(set: .whitespacesAndNewlines)
    }
}
