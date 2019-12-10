//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class ProgressStackView: UIStackView {

    private static var percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static var pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    @IBOutlet private weak var progressTitle: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var progressPointsScored: UILabel!
    @IBOutlet private weak var progressPercentageScored: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.progressView.layer.roundCorners(for: .inner)
        self.progressView.trackTintColor = Brand.default.colors.primaryLight
        self.progressView.progressTintColor = Brand.default.colors.primary
    }

    func configure(for progress: ExerciseProgress) {
        self.isHidden = progress.pointsAvailable()

        let scored = progress.pointsScored.flatMap(Self.pointsFormatter.string(for:)) ?? "-"
        let possible = progress.pointsPossible.flatMap(Self.pointsFormatter.string(for:)) ?? "-"

        let format = NSLocalizedString("course.progress.points %@ of %@ points", comment: "course progress points")
        let scoredText = String.localizedStringWithFormat(format, scored, possible)
        self.progressPointsScored.text = scoredText

        let percentageScored = progress.calculatePercentage()
        self.progressView.progress = Float(percentageScored ?? 0)
        self.progressPercentageScored.text = percentageScored.flatMap(Self.percentageFormatter.string(for:)) ?? "-"
    }
}
