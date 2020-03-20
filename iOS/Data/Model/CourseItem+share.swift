//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import LinkPresentation
import UIKit

extension CourseItem: UIActivityItemSource {

    var combinedTitle: String {
        return [self.title, self.section?.course?.title].compactMap { $0 }.joined(separator: " - ")
    }

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.combinedTitle
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.url
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return self.combinedTitle
    }

    @available(iOS 13.0, *)
    public func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = self.url
        metadata.url = self.url
        metadata.title = self.combinedTitle
        return metadata
    }

}

extension CourseItem {

    public func share(viewController: UIViewController) {
        let activityItems = [self]
        let activityViewController = UIActivityViewController(activityItems: [activityItems], applicationActivities: nil)
        viewController.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

}
