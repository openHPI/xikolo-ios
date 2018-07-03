//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SafariServices
import UIKit

class RichtextViewController: UIViewController {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var textView: UITextView!

    var courseItem: CourseItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateView(for: self.courseItem)
        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { syncResult in
            CoreDataHelper.viewContext.perform {
                let object = CoreDataHelper.viewContext.existingTypedObject(with: syncResult.objectId) as? CourseItem
                guard let courseItem = object else {
                    log.warning("Failed to retrieve course item to display")
                    return
                }

                self.courseItem = courseItem
                DispatchQueue.main.async {
                    self.updateView(for: self.courseItem)
                }
            }
        }

        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0
        CrashlyticsHelper.shared.setObjectValue(self.courseItem.id, forKey: "item_id")
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
        MarkdownHelper.attributedString(for: markdown).onSuccess(DispatchQueue.main.context) { attributedString in
            self.textView.attributedText = attributedString
            self.textView.isHidden = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.richtextViewController.openInWebView(segue: segue) {
            typedInfo.destination.courseItem = self.courseItem
        }
    }

}

extension RichtextViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return !AppNavigator.handle(URL, on: self)
    }

}
