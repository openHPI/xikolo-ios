//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Down
import HTMLStyler

struct MarkdownHelper {

    static let parser: Parser = {
        var parser = Parser()
        parser.styleCollection = DefaultStyleCollection(tintColor: Brand.Color.primary)
        return parser
    }()

    static func parse(_ string: String) throws -> NSMutableAttributedString {
        let html = try? Down(markdownString: string).toHTML()
//        return NSMutableAttributedString(string: html ?? "")
        return self.parser.attributedString(for: html ?? "")

//        let parser = Down(markdownString: string)
//
//        #if os(tvOS)
//            let color = "white"
//        #else
//            let color = "black"
//        #endif
//
//        if let attributedString = try? parser.toAttributedStringWithFont(font: "-apple-system-body", color: color) {
//            let mutableString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
//            return mutableString
//        } else {
//            throw XikoloError.markdownError
//        }
    }

    static func trueScheme(for url: URL) -> URL? {
        var url = url
        if url.scheme == "applewebdata" { // replace applewebdata with baseURL for relative urls in markdown
            var absoluteString = url.absoluteString
            let trimmedUrlString = absoluteString.stringByRemovingRegexMatches(pattern: "^(?:applewebdata://[0-9A-Z-]*/?)",
                                                                               replaceWith: Routes.base.absoluteString + "/")
            guard let trimmedString = trimmedUrlString else { return nil }
            guard let trimmedURL = URL(string: trimmedString) else { return nil }
            url = trimmedURL
        }

        guard url.scheme?.hasPrefix("http") ?? false else { return nil }

        return url
    }

}

extension DownAttributedStringRenderable {

    func toAttributedStringWithFont(_ options: DownOptions = .default, font: String, color: String) throws -> NSAttributedString {
        let htmlResponse = try self.toHTML(options)
        let html = "<span style=\"font: \(font); color: \(color);\">\(htmlResponse)</span>"
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]
        let mutableString = try NSMutableAttributedString(data: Data(html.utf8), options: options, documentAttributes: nil)
        return mutableString //.trimmedAttributedString(set: .whitespacesAndNewlines)
    }

}
