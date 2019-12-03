//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseTotalProgressView: UIView {

    @IBOutlet weak var courseProgressTitle: UILabel!

    @IBOutlet weak var mainProgressStackView: ProgressStackView!
    @IBOutlet weak var selfTestProgressStackView: ProgressStackView!
    @IBOutlet weak var bonusTestProgressStackView: ProgressStackView!
    @IBOutlet weak var visitProgressStackView: VisitProgressStackView!

    func configure(for courseProgress: CourseProgress, showCourseTitle: Bool) {

        self.courseProgressTitle.text = "Total"
        mainProgressStackView.configure(for: courseProgress.mainProgress)
        selfTestProgressStackView.configure(for: courseProgress.selftestProgress)
        bonusTestProgressStackView.configure(for: courseProgress.bonusProgress)
        visitProgressStackView.configure(for: courseProgress.visitProgress)
    }

}
