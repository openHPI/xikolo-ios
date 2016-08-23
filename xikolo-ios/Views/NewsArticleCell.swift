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

    func configure(newsArticle: NewsArticle) {
        readStateView.backgroundColor = Brand.TintColor
        titleView.text = newsArticle.title
        descriptionView.text = newsArticle.text
    }

}
