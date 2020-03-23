//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Down
import HTMLStyler

struct XikoloImageLoader: ImageLoader {

    public static func dataTask(for url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        guard let absoluteURL = URL(string: url.absoluteString, relativeTo: Routes.base) else {
            return URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        }

        return URLSession.shared.dataTask(with: absoluteURL, completionHandler: completionHandler)
    }

}

public enum MarkdownHelper {

    static let parser: Parser = {
        var parser = Parser()
        parser.styleCollection = DefaultStyleCollection(tintColor: Brand.default.colors.primary)
        return parser
    }()

    static let imageParser: Parser = {
        var parser = Parser()
        parser.styleCollection = DefaultStyleCollection(tintColor: Brand.default.colors.primary, imageLoader: XikoloImageLoader.self)
        return parser
    }()

    public static func string(for markdown: String) -> String {
        let html = try? Down(markdownString: markdown).toHTML()
        return self.parser.string(for: html ?? "")
    }


    public static func attributedString(for markdown: String) -> NSAttributedString {
        if #available(iOS 11, *) {
            let string = self.string(for: markdown) // parse markdown first as included URLs can skew the result
            let dominantLanguage = NSLinguisticTagger.dominantLanguage(for: string)
            if ["ar", "he", "fa"].contains(dominantLanguage) {
                let attributedString = try? Down(markdownString: markdown).toAttributedString(styler: DownStyler())
                return attributedString ?? NSAttributedString()
            } else {
                let html = try? Down(markdownString: markdown).toHTML()
                return self.parser.attributedString(for: html ?? "")
            }
        } else {
            let attributedString = try? Down(markdownString: markdown).toAttributedString(styler: DownStyler())
            return attributedString ?? NSAttributedString()
        }
    }

    public static func attributedStringWithImages(for markdown: String, layoutChangeHandler: (() -> Void)? = nil) -> NSAttributedString {
        if #available(iOS 11, *) {
            let string = self.string(for: markdown) // parse markdown first as included URLs can skew the result
            let dominantLanguage = NSLinguisticTagger.dominantLanguage(for: string)
            if ["ar", "he", "fa"].contains(dominantLanguage) {
                let attributedString = try? Down(markdownString: markdown).toAttributedString(styler: DownStyler())
                return attributedString ?? NSAttributedString()
            } else {
                let html = try? Down(markdownString: markdown).toHTML()
                return self.imageParser.attributedString(for: html ?? "", with: layoutChangeHandler)
            }
        } else {
            let attributedString = try? Down(markdownString: markdown).toAttributedString(styler: DownStyler())
            return attributedString ?? NSAttributedString()
        }
    }

}
