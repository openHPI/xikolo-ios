//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Down
import HTMLStyler

struct XikoloImageLoader: ImageLoader {

    public static func load(for url: URL) -> UIImage? {
        guard let absoluteURL = URL(string: url.absoluteString, relativeTo: Routes.base) else { return nil }
        guard let data = try? Data(contentsOf: absoluteURL) else { return nil }
        return UIImage(data: data)
    }

}

public enum MarkdownHelper {

    static let parser: Parser = {
        var parser = Parser()
        parser.styleCollection = DefaultStyleCollection(tintColor: Brand.default.colors.primary, imageLoader: XikoloImageLoader.self)
        return parser
    }()

    public static func string(for markdown: String) -> String {
        let html = try? Down(markdownString: markdown).toHTML()
        return self.parser.string(for: html ?? "")
    }

    public static func attributedString(for markdown: String) -> Future<NSMutableAttributedString, XikoloError> {
        return Future { complete in
            let html = try? Down(markdownString: markdown).toHTML()
            let attributedString = self.parser.attributedString(for: html ?? "")
            complete(.success(attributedString))
        }
    }

    public static func trueScheme(for url: URL) -> URL? {
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
