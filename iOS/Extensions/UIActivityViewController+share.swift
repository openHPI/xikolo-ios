//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation
import UIKit

extension UIActivityViewController {

    static func make(for course: Course, on viewController: UIViewController?) -> UIActivityViewController {
        let controller = Self(activityItems: [course], applicationActivities: nil)
        controller.completionWithItemsHandler = { activityType, completed, _, _ in
            let context: [String: String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.createEvent(.shareCourse, resourceType: .course, resourceId: course.id, on: viewController, context: context)
        }

        return controller
    }

}
