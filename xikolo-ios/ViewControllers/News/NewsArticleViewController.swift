//
//  NewsArticleViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Down
import SafariServices

class NewsArticleViewController : UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateView: UILabel!

    var newsArticle: NewsArticle!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let date = newsArticle.published_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateView.text = dateFormatter.string(from: date)
        }

        titleView.text = newsArticle.title
        titleView.heroID = "news_headline_" + newsArticle.id

        textView.delegate = self
        if let newsText = newsArticle.text {
            let markDown = try? MarkdownHelper.parse(newsText) // TODO: Error handling
            self.textView.attributedText = markDown
        }
        //save read state to server
        newsArticle.visited = true
        SpineHelper.save(NewsArticleSpine.init(newsItem: newsArticle))
    }

}

extension NewsArticleViewController: UITextViewDelegate {

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
