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
            return 0.0
        }

        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = NumberFormatter.Style.percent
        percentageFormatter.maximumFractionDigits = 1

        var percentageScored : Double = 0
        percentageScored = (pointsScored / pointsPossible)

        return Float(percentageScored)
    }

    func formatToPercentage(number: Float) -> String {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = NumberFormatter.Style.percent
        percentageFormatter.minimumFractionDigits = 1
        percentageFormatter.maximumFractionDigits = 1

        return percentageFormatter.string(for: number) ?? "0.0"

    }

    func configureMainProgressStack(for mainProgress: ExerciseProgress) {
        self.mainProgressImageView.image = R.image.courseItemIcons.homework()

        let percentageScored = calculatePercentage(pointsScored: mainProgress.pointsScored!, pointsPossible: mainProgress.pointsPossible!)

        self.mainProgressView.progress = percentageScored
        self.mainProgressPercentageScored.text = formatToPercentage(number: percentageScored)

        let scoredText = String(format: "%.1f", mainProgress.pointsScored!) + " of " + String(format: "%.1f", mainProgress.pointsPossible!) + " scored"
        self.mainProgressPointsScored.text = scoredText

    }

    func configureSelfTestProgressStack(for selfTestProgress: ExerciseProgress) {
        self.selfTestProgressImageView.image = R.image.courseItemIcons.quiz()

        let scoredText = String(format: "%.1f", selfTestProgress.pointsScored!) + " of " + String(format: "%.1f", selfTestProgress.pointsPossible!) + " scored"
        self.selfTestProgressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: selfTestProgress.pointsScored!, pointsPossible: selfTestProgress.pointsPossible!)

        self.selfTestProgressView.progress = percentageScored
        self.selfTestProgressPercentageScored.text = formatToPercentage(number: percentageScored)

    }

    func configureBonusProgressStack(for bonusProgress: ExerciseProgress) {
        self.selfTestProgressImageView.image = R.image.courseItemIcons.bonusQuiz()

        let scoredText = String(format: "%.1f", bonusProgress.pointsScored!) + " of " + String(format: "%.1f", bonusProgress.pointsPossible!) + " scored"
        self.bonusProgressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: bonusProgress.pointsScored!, pointsPossible: bonusProgress.pointsPossible!)

        self.bonusProgressView.progress = percentageScored
        self.bonusProgressPercentageScored.text = formatToPercentage(number: percentageScored)

    }

    func configure(for sectionProgress: SectionProgress, showCourseTitle: Bool) {

        self.sectionProgressTitle.text = sectionProgress.title

        if sectionProgress.mainProgress.pointsPossible! > 0.0 {
            configureMainProgressStack(for: sectionProgress.mainProgress)
        } else {
            self.mainProgressStackView.isHidden = true
        }

        if sectionProgress.selftestProgress.pointsPossible! > 0.0 {
            configureSelfTestProgressStack(for: sectionProgress.selftestProgress)
        } else {
            self.selfTestProgressStackView.isHidden = true
        }

        if sectionProgress.bonusProgress.pointsPossible! > 0.0 {
            configureBonusProgressStack(for: sectionProgress.bonusProgress)
        } else {
            self.bonusProgressStackView.isHidden = true
        }
    }

}
