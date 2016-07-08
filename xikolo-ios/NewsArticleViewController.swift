//
//  NewsArticleViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class NewsArticleViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    var newsArticle: NewsArticle!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = newsArticle.title
        textView.text = newsArticle.text
    }
    
}

