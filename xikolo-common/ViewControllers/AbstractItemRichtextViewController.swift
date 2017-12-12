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

        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { objectId in
            CoreDataHelper.viewContext.perform {
                guard let courseItem = CoreDataHelper.viewContext.existingTypedObject(with: objectId) as? CourseItem else {
                    print("Warning: Failed to retrieve course item to display")
                    return
                }

                self.courseItem = courseItem
                DispatchQueue.main.async {
                    self.updateView(for: self.courseItem)
                }
            }
        }
    }

    private func updateView(for courseItem: CourseItem) {
        self.titleView.text = self.courseItem.title

        guard let richText = courseItem.content as? RichText else { return }

        if let markdown = richText.text {
            self.display(markdown: markdown)
        }
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
