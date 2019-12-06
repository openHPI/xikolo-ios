//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit
import Common

class VisitProgressStackView: UIStackView {

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

    @IBOutlet weak var progressTitle: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressItemsVisited: UILabel!
    @IBOutlet weak var progressItemsPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.progressView.layer.roundCorners(for: .inner)
        self.progressView.trackTintColor = Brand.default.colors.primaryLight
        self.progressView.progressTintColor = Brand.default.colors.primary
    }

    func configure(for progress: VisitProgress) {

        let visited = progress.itemsVisited.flatMap(Self.pointsFormatter.string(for:)) ?? "-"
        let available = progress.itemsAvailable.flatMap(Self.pointsFormatter.string(for:)) ?? "-"

        let format = NSLocalizedString("course.progress.visited %@ of %@ visited", comment: "course progress visited")
        let visitedText = String.localizedStringWithFormat(format, visited, available)
        self.progressItemsVisited.text = visitedText

        let percentageVisited = progress.calculatePercentage()
        self.progressView.progress = Float(percentageVisited ?? 0)
        self.progressItemsPercentage.text = percentageVisited.flatMap(Self.percentageFormatter.string(for:)) ?? "-"
    }
}
