//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

/// Should be a subclass of `UITableViewHeaderFooterView`. This resolves potential resizing issues.
/// See https://gist.github.com/smileyborg/50de5da1c921b73bbccf7f76b3694f6a
class CourseProgressView: UITableViewHeaderFooterView {

    @IBOutlet private weak var mainProgressStackView: ExerciseProgressStackView!
    @IBOutlet private weak var selfTestProgressStackView: ExerciseProgressStackView!
    @IBOutlet private weak var bonusTestProgressStackView: ExerciseProgressStackView!
    @IBOutlet private weak var visitProgressStackView: VisitProgressStackView!

    func configure(for courseProgress: CourseProgress, showCourseTitle: Bool) {
        self.mainProgressStackView.configure(for: courseProgress.mainProgress)
        self.selfTestProgressStackView.configure(for: courseProgress.selftestProgress)
        self.bonusTestProgressStackView.configure(for: courseProgress.bonusProgress)
        self.visitProgressStackView.configure(for: courseProgress.visitProgress)
    }

}
