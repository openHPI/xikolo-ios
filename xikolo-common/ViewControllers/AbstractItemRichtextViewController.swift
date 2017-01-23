//
//  AbstractItemRichtextViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 17.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class AbstractItemRichtextViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var textView: UITextView!

    var courseItem: CourseItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        RichTextHelper.refreshRichText(courseItem.content as! RichText).onSuccess { richText in
            if let markdown = richText.text {
                let parser = MarkdownParser()
                #if os(tvOS)
                    parser.setColor(UIColor.white)
                    self.textView.attributedText = parser.parse(markdown)
                #endif
                #if os(iOS)
                    let markDown = try? MarkdownHelper.parse(markdown) // TODO: Error handling
                    self.textView.attributedText = markDown
                #endif

                self.richTextLoaded()
            }
        }

        titleView.text = courseItem.title
    }

    func richTextLoaded() {
    }

}
