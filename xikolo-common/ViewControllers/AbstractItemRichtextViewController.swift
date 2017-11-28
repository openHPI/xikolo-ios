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

        self.titleView.text = self.courseItem.title
        self.loadRichText()
    }

    func loadRichText() {
        guard let richText = courseItem.content as? RichText else {
            // Content item is no rich text
            return
        }

        // Load local version if existing
        if let markdown = richText.text {
            self.display(markdown: markdown)
        }

        self.courseItem.content?.notifyOnChange(self, updateHandler: {
            if let markdown = (self.courseItem.content as? RichText)?.text {
                self.display(markdown: markdown)
            }
        }, deleteHandler: {})

        // Refresh rich text
        RichTextHelper.syncRichText(courseItem.content as! RichText)
    }

    func display(markdown: String) {
        let markDown = try? MarkdownHelper.parse(markdown) // TODO: Error handling
        self.textView.attributedText = markDown
        self.richTextLoaded()
    }

    func richTextLoaded() {
        // Do nothing. Subclasses can customize this method.
    }

}
