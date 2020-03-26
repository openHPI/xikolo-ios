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

        let promise = Promise<NSMutableAttributedString, XikoloError>()

        if #available(iOS 11, *) {
            let string = self.string(for: markdown) // parse markdown first as included URLs can skew the result
            let dominantLanguage = NSLinguisticTagger.dominantLanguage(for: string)
            if ["ar", "he", "fa"].contains(dominantLanguage) {
                let attributedString = try? Down(markdownString: markdown).toAttributedString(styler: DownStyler())
                promise.success(NSMutableAttributedString(attributedString: attributedString ?? NSAttributedString()))
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    let html = try? Down(markdownString: markdown).toHTML()
                    let attributedString = self.parser.attributedString(for: html ?? "")
                    promise.success(attributedString)
                }
            }
        } else {
            let attributedString = try? Down(markdownString: markdown).toAttributedString(styler: DownStyler())
            promise.success(NSMutableAttributedString(attributedString: attributedString ?? NSAttributedString()))
        }

        return promise.future
    }

}
