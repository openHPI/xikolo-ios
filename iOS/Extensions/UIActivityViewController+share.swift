//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation
import UIKit

extension UIActivityViewController {

    convenience init?(course: Course) {
        self.init(activityItems: [course], applicationActivities: nil)
    }

}

extension UIActivityViewController {

    convenience init?(courseItem: CourseItem) {
        self.init(activityItems: [courseItem], applicationActivities: nil)
    }

}
