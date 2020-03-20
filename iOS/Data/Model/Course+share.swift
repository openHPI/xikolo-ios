//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import LinkPresentation
import UIKit

extension Course: UIActivityItemSource {

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return self.title ?? ""
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.url
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return self.title ?? ""
    }

    @available(iOS 13.0, *)
    public func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = self.url
        metadata.url = self.url
        metadata.title = self.title
        return metadata
    }

}

extension Course {

    public func share(viewController: UIViewController) {

        let activityItems = [self]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            let context: [String: String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.createEvent(.shareCourse, resourceType: .course, resourceId: self.id, on: viewController, context: context)
        }

        viewController.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

}
