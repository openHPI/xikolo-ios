//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Down

public enum MarkdownHelper {

    static func dataTask(for url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        guard let absoluteURL = URL(string: url.absoluteString, relativeTo: Routes.base) else {
            return URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        }

        return URLSession.shared.dataTask(with: absoluteURL, completionHandler: completionHandler)
    }

    public static func string(for markdown: String) -> String {
        // Uses styler on purpose. Otherwise Down uses Webkit to render the attributed string
        // which must be executed on the main thread, or the app will crash
        let down = Down(markdownString: markdown)
        let attributedString = try? down.toAttributedString(styler: DownStyler())
        return attributedString?.string ?? ""
    }

    public static func attributedString(for markdown: String) -> NSAttributedString {
        let down = Down(markdownString: markdown)
        let styler = NoImagesStyler(configuration: DownStylerConfiguration.makeDynamicConfiguration())
        let attributedString = try? down.toAttributedString(.smartUnsafe, styler: styler)
        return attributedString ?? NSAttributedString()
    }

    public static func attributedStringWithImages(for markdown: String, layoutChangeHandler: (() -> Void)? = nil) -> NSAttributedString {
        let down = Down(markdownString: markdown)
        let styler = AsyncImagesStyler(imageLoader: self.dataTask(for:completionHandler:),
                                       layoutChangeHandler: layoutChangeHandler,
                                       configuration: DownStylerConfiguration.makeDynamicConfiguration())
        let attribtuedString = try? down.toAttributedString(.smartUnsafe, styler: styler)
        return attribtuedString ?? NSAttributedString()
    }

}
