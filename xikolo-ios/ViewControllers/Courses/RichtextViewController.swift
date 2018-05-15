//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SafariServices
import UIKit

class RichtextViewController: AbstractItemRichtextViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets.zero
        self.textView.textContainer.lineFragmentPadding = 0
        CrashlyticsHelper.shared.setObjectValue(self.courseItem.id, forKey: "item_id")
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
