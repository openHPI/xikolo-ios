//
//  RichtextViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 17.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class RichtextViewController: AbstractItemRichtextViewController {

    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        RichTextHelper.refreshRichText(courseItem.content as! RichText).onSuccess { richText in
            if let markdown = richText.markup {
                self.textView.attributedText = MarkdownParser.parse(markdown)
            }
        }
        titleLabel.text = courseItem.title
    }

}
