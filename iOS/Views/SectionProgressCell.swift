//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class SectionProgressCell: UITableViewCell {

    @IBOutlet weak var sectionProgressTitle: UILabel!

    @IBOutlet weak var mainProgressStackView: ProgressStackView!
    @IBOutlet weak var selfTestProgressStackView: ProgressStackView!
    @IBOutlet weak var bonusTestProgressStackView: ProgressStackView!
    @IBOutlet weak var visitProgressStackView: VisitProgressStackView!


    func configure(for sectionProgress: SectionProgress, showCourseTitle: Bool) {

        self.sectionProgressTitle.text = sectionProgress.title
        mainProgressStackView.configure(for: sectionProgress.mainProgress)
        selfTestProgressStackView.configure(for: sectionProgress.selftestProgress)
        bonusTestProgressStackView.configure(for: sectionProgress.bonusProgress)
        visitProgressStackView.configure(for: sectionProgress.visitProgress)
    }

}
