//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SafariServices
import UIKit

class RichtextViewController: AbstractItemRichtextViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0
        CrashlyticsHelper.shared.setObjectValue(self.courseItem.id, forKey: "item_id")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openInWebView" {
            let webView = segue.destination.require(toHaveType: CourseItemWebViewController.self)
            webView.courseItem = self.courseItem
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}
