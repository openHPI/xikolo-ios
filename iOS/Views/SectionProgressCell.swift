//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class SectionProgressCell: UITableViewCell {

    @IBOutlet weak var sectionProgressTitle: UILabel!

    @IBOutlet weak var mainProgressStackView: UIStackView!
    @IBOutlet weak var mainProgressView: UIProgressView!
    @IBOutlet weak var mainProgressImageView: UIImageView!
    @IBOutlet weak var mainProgressPointsScored: UILabel!
    @IBOutlet weak var mainProgressPercentageScored: UILabel!

    @IBOutlet weak var selfTestProgressStackView: UIStackView!
    @IBOutlet weak var selfTestProgressView: UIProgressView!
    @IBOutlet weak var selfTestProgressImageView: UIImageView!
    @IBOutlet weak var selfTestProgressPointsScored: UILabel!
    @IBOutlet weak var selfTestProgressPercentageScored: UILabel!

    @IBOutlet weak var bonusProgressStackView: UIStackView!
    @IBOutlet weak var bonusProgressView: UIProgressView!
    @IBOutlet weak var bonusProgressImageView: UIImageView!
    @IBOutlet weak var bonusProgressPointsScored: UILabel!
    @IBOutlet weak var bonusProgressPercentageScored: UILabel!
    
    func calculatePercentage(pointsScored: Double, pointsPossible: Double) -> Float {
        if pointsScored == 0 {
            return Float(0.0)
        }
        var percentageScored : Double = 0
        percentageScored = (pointsScored / pointsScored) * 100
        return Float(percentageScored)
    }

    func configureMainProgressStack(for mainProgress: ExerciseProgress) {
        self.mainProgressImageView.image = R.image.courseItemIcons.homework()

        let scoredText = String(format: "%.1f", mainProgress.pointsScored!) + " of " + String(format: "%.1f", mainProgress.pointsPossible!)
        self.mainProgressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: mainProgress.pointsScored!, pointsPossible: mainProgress.pointsPossible!)
        self.mainProgressPercentageScored.text = String(format: "%.1f", percentageScored) + "%"
        self.mainProgressView.progress = percentageScored / 100

    }

    func configureSelfTestProgressStack(for selfTestProgress: ExerciseProgress) {
        self.selfTestProgressImageView.image = R.image.courseItemIcons.quiz()

        let scoredText = String(format: "%.1f", selfTestProgress.pointsScored!) + " of " + String(format: "%.1f", selfTestProgress.pointsPossible!)
        self.selfTestProgressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: selfTestProgress.pointsScored!, pointsPossible: selfTestProgress.pointsPossible!)
        self.selfTestProgressPercentageScored.text = String(format: "%.1f", percentageScored) + "%"
        self.selfTestProgressView.progress = percentageScored / 100

    }

    func configureBonusProgressStack(for bonusProgress: ExerciseProgress) {
        self.selfTestProgressImageView.image = R.image.courseItemIcons.bonusQuiz()

        let scoredText = String(format: "%.1f", bonusProgress.pointsScored!) + " of " + String(format: "%.1f", bonusProgress.pointsPossible!)
        self.bonusProgressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: bonusProgress.pointsScored!, pointsPossible: bonusProgress.pointsPossible!)
        self.bonusProgressPercentageScored.text = String(format: "%.1f", percentageScored) + "%"
        self.bonusProgressView.progress = percentageScored / 100

    }

    func configure(for sectionProgress: SectionProgress, showCourseTitle: Bool) {

        self.sectionProgressTitle.text = sectionProgress.title

        configureMainProgressStack(for: sectionProgress.mainProgress)
        configureSelfTestProgressStack(for: sectionProgress.selftestProgress)
        configureBonusProgressStack(for: sectionProgress.bonusProgress)

    }

}
