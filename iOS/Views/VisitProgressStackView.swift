//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class VisitProgressStackView: UIStackView {

    private static var percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static var visitFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    @IBOutlet private weak var progressTitle: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var progressItemsVisited: UILabel!
    @IBOutlet private weak var progressItemsPercentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.progressView.layer.roundCorners(for: .inner)
        self.progressView.trackTintColor = Brand.default.colors.primaryLight
        self.progressView.progressTintColor = Brand.default.colors.primary
    }

    func configure(for progress: VisitProgress) {
        let visited = progress.itemsVisited.flatMap(Self.visitFormatter.string(for:)) ?? "-"
        let available = progress.itemsAvailable.flatMap(Self.visitFormatter.string(for:)) ?? "-"

        let format = NSLocalizedString("course.progress.visited %@ of %@ visited", comment: "label visit progess with absolute values. n out of m")
        let visitedText = String.localizedStringWithFormat(format, visited, available)
        self.progressItemsVisited.text = visitedText

        self.progressView.progress = Float(progress.percentage ?? 0)
        self.progressItemsPercentage.text = progress.percentage.flatMap(Self.percentageFormatter.string(for:)) ?? "-"
    }

}
