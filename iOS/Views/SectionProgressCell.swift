//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class SectionProgressCell: UITableViewCell {

    @IBOutlet private weak var sectionProgressTitle: UILabel!

    @IBOutlet private weak var mainProgressStackView: ProgressStackView!
    @IBOutlet private weak var selfTestProgressStackView: ProgressStackView!
    @IBOutlet private weak var bonusTestProgressStackView: ProgressStackView!
    @IBOutlet private weak var visitProgressStackView: VisitProgressStackView!

    func configure(for sectionProgress: SectionProgress, showCourseTitle: Bool) {

        self.sectionProgressTitle.text = sectionProgress.title
        mainProgressStackView.configure(for: sectionProgress.mainProgress)
        selfTestProgressStackView.configure(for: sectionProgress.selftestProgress)
        bonusTestProgressStackView.configure(for: sectionProgress.bonusProgress)
        visitProgressStackView.configure(for: sectionProgress.visitProgress)
    }

}
