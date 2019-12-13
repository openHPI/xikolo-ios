//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class SectionProgressCell: UITableViewCell {

    @IBOutlet private weak var sectionTitleLabel: UILabel!
    @IBOutlet private weak var mainProgressStackView: ExerciseProgressStackView!
    @IBOutlet private weak var selfTestProgressStackView: ExerciseProgressStackView!
    @IBOutlet private weak var bonusTestProgressStackView: ExerciseProgressStackView!
    @IBOutlet private weak var visitProgressStackView: VisitProgressStackView!

    func configure(for sectionProgress: SectionProgress, showCourseTitle: Bool) {
        self.sectionTitleLabel.text = sectionProgress.title
        self.mainProgressStackView.configure(for: sectionProgress.mainProgress)
        self.selfTestProgressStackView.configure(for: sectionProgress.selftestProgress)
        self.bonusTestProgressStackView.configure(for: sectionProgress.bonusProgress)
        self.visitProgressStackView.configure(for: sectionProgress.visitProgress)
    }

}
