//
//  NewsArticleViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Down

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
        if let newsText = newsArticle.text {
            let markDown = try? MarkdownHelper.parse(newsText) // TODO: Error handling
            self.textView.attributedText = markDown
        }
        //save read state to server
        newsArticle.visited = true
        SpineHelper.save(NewsArticleSpine.init(newsItem: newsArticle))
    }

}
