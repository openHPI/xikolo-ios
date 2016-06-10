//
//  TextViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ItemRichTextController : UIViewController {

    @IBOutlet weak var textView: UITextView!

    var courseItem: CourseItem!

    override func viewDidLoad() {
        textView.selectable = true
        textView.panGestureRecognizer.allowedTouchTypes = [ UITouchType.Indirect.rawValue ]

        RichTextHelper.refreshRichText(courseItem.content as! RichText).onSuccess { richText in
            if let markdown = richText.markup {
                self.textView.attributedText = MarkdownParser.parse(markdown)
            }
        }
    }

}
