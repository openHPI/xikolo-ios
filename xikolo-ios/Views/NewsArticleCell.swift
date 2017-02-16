//
//  NewsArticleCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class NewsArticleCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var courseView: UILabel!
    @IBOutlet weak var roundedTagBackgroundView: UIView!

    func configure(_ newsArticle: NewsArticle) {
        readStateView.backgroundColor = Brand.TintColor

        descriptionView.isScrollEnabled = false
        descriptionView.textContainer.maximumNumberOfLines = 4
        descriptionView.textContainer.lineBreakMode = .byTruncatingTail

        if let date = newsArticle.published_at {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateView.text = dateFormatter.string(from: date)
        }

        titleView.text = newsArticle.title

        if let newsText = newsArticle.text {
            let markDown = try? MarkdownHelper.parse(newsText) // TODO: Error handling
            self.descriptionView.attributedText = markDown
        }
        readStateView.isHidden = newsArticle.visited ?? true

        roundedTagBackgroundView.isHidden = newsArticle.course == nil
        courseView.text = newsArticle.course?.title
    }

}
