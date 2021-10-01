//
//  Created for xikolo-ios under GPL-3.0 license.
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

    func configure(for courseProgress: CourseProgress?) {
        self.mainProgressStackView.isHidden = courseProgress == nil
        self.selfTestProgressStackView.isHidden = courseProgress == nil
        self.bonusTestProgressStackView.isHidden = courseProgress == nil
        self.visitProgressStackView.isHidden = courseProgress == nil

        if let progress = courseProgress {
            self.mainProgressStackView.configure(for: progress.mainProgress)
            self.selfTestProgressStackView.configure(for: progress.selftestProgress)
            self.bonusTestProgressStackView.configure(for: progress.bonusProgress)
            self.visitProgressStackView.configure(for: progress.visitProgress)
        }
    }

}
