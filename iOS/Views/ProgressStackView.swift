//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit
import Common

class ProgressStackView: UIStackView {

    @IBOutlet weak var progressTitle: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressPointsScored: UILabel!
    @IBOutlet weak var progressPercentageScored: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.progressView.layer.roundCorners(for: .inner)

        self.progressView.trackTintColor = Brand.default.colors.primaryLight
        self.progressView.progressTintColor = Brand.default.colors.primary
    }

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

    func configure(for progress: ExerciseProgress) {

        if progress.pointsPossible! > 0.0 {
//            self.isHidden = false
        } else {
//            self.isHidden = true
        }

        let scoredText = String(format: "%.1f", progress.pointsScored!) + " of " + String(format: "%.1f", progress.pointsPossible!) + " scored"
        self.progressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: progress.pointsScored!, pointsPossible: progress.pointsPossible!)

        self.progressView.progress = percentageScored
        self.progressPercentageScored.text = formatToPercentage(number: percentageScored)

    }
}
