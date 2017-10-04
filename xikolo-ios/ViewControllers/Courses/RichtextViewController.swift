//
//  RichtextViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 17.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import SafariServices

class RichtextViewController : AbstractItemRichtextViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0
    }

}

extension RichtextViewController: UITextViewDelegate {

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
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.preferredControlTintColor = Brand.TintColor
        return false
    }

    func getURL(forString string: String) -> URL? {
        return URL(string: string) // necessary because someone clever put the argument in CAPS in the function above
    }

}
