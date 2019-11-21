//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit
import Common

class ProgressStackView: UIStackView {

    private static var percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

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

    // TODO: move to ExerciseProgress
    func calculatePercentage(pointsScored: Double?, pointsPossible: Double?) -> Double? {
        guard let scored = pointsScored else { return nil }
        guard let possible = pointsPossible, !possible.isZero else { return nil }
        return scored / possible
    }

    func configure(for progress: ExerciseProgress) {
        self.isHidden = progress.pointsPossible?.isZero ?? true // TODO: move to ExerciseProgress -> progress.pointsAvaialble

        // TODO: use numberformatters (comma vs points as decimal point) + localization
        let scoredText = String(format: "%.1f", progress.pointsScored!) + " of " + String(format: "%.1f", progress.pointsPossible!) + " points"
        self.progressPointsScored.text = scoredText

        let percentageScored = calculatePercentage(pointsScored: progress.pointsScored, pointsPossible: progress.pointsPossible)
        self.progressView.progress = Float(percentageScored ?? 0)
        self.progressPercentageScored.text = percentageScored.flatMap(Self.percentageFormatter.string(for:)) ?? "-"
    }
}
