//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class AbstractItemRichtextViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel! // swiftlint:disable:this private_outlet
    @IBOutlet weak var textView: UITextView! // swiftlint:disable:this private_outlet

    var courseItem: CourseItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { syncResult in
            CoreDataHelper.viewContext.perform {
                guard let courseItem = CoreDataHelper.viewContext.existingTypedObject(with: syncResult.objectId) as? CourseItem else {
                    log.warning("Failed to retrieve course item to display")
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

        guard let richText = courseItem.content as? RichText, let markdown = richText.text else {
            self.textView.isHidden = true
            return
        }

        self.display(markdown: markdown)
    }

    func display(markdown: String) {
        let markDown = try? MarkdownHelper.parse(markdown)
        self.textView.attributedText = markDown
        self.textView.isHidden = false
        self.richTextLoaded()
    }

    func richTextLoaded() {
        // Do nothing. Subclasses can customize this method.
    }

}
