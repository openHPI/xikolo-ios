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
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var dateView: UILabel!

    func configure(newsArticle: NewsArticle) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        let date = newsArticle.published_at!

        dateView.text = dateFormatter.stringFromDate(date)
        titleView.text = newsArticle.title
        descriptionView.text = newsArticle.text
        dateView.text = dateFormatter.stringFromDate(date)
    }

}
