//
//  NewsTableViewCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var readStateView: UIView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var newsArticle: NewsArticle! {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        titleLable.text = newsArticle.title
        descriptionLabel.text = newsArticle.text
    }

}
