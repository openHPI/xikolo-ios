//
//  RichtextDelegate.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 09.03.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

protocol RichTextViewDelegate : UITextViewDelegate {

}

extension RichTextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var url = URL
        if (URL.scheme == "applewebdata") { // replace applewebdata with baseURL for relative urls in markdown
            var absoluteString = URL.absoluteString
            let trimmedUrlString = absoluteString.stringByRemovingRegexMatches(pattern: "^(?:applewebdata://[0-9A-Z-]*/?)", replaceWith: Brand.BaseURL + "/")
            guard let trimmedString = trimmedUrlString else { return false }
            guard let trimmedURL = getURL(forString: trimmedString) else { return false }
            url = trimmedURL
        }
        if !(url.scheme?.hasPrefix("http") ?? false) { // abort if it still isnt http
            return false
        }

        if AppNavigator.handle(url) { // We can open the link inside the app
            return false
        }

        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.preferredControlTintColor = Brand.windowTintColor
        return false
    }

    func getURL(forString string: String) -> URL? {
        return URL(string: string) // necessary because someone clever put the argument in CAPS in the function above
    }

}
