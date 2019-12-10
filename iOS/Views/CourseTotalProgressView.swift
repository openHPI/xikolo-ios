//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

/// Should be a subclass of `UITableViewHeaderFooterView`. This resolves potential resizing issues.
/// See https://gist.github.com/smileyborg/50de5da1c921b73bbccf7f76b3694f6a
class CourseTotalProgressView: UITableViewHeaderFooterView {

    @IBOutlet weak var courseProgressTitle: UILabel!

    @IBOutlet weak var mainProgressStackView: ProgressStackView!
    @IBOutlet weak var selfTestProgressStackView: ProgressStackView!
    @IBOutlet weak var bonusTestProgressStackView: ProgressStackView!
    @IBOutlet weak var visitProgressStackView: VisitProgressStackView!

    func configure(for courseProgress: CourseProgress, showCourseTitle: Bool) {

        mainProgressStackView.configure(for: courseProgress.mainProgress)
        selfTestProgressStackView.configure(for: courseProgress.selftestProgress)
        bonusTestProgressStackView.configure(for: courseProgress.bonusProgress)
        visitProgressStackView.configure(for: courseProgress.visitProgress)
    }

}
