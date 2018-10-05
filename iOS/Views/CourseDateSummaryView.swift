//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseDateSummaryView: UIStackView {

    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var todayCountLabel: UILabel!
    @IBOutlet private weak var nextCountLabel: UILabel!
    @IBOutlet private weak var allCountLabel: UILabel!
    @IBOutlet private var pills: [UIView]!

    weak var delegate: CourseDateOverviewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.container.layer.cornerRadius = 6.0

//        self.container.backgroundColor = .green
//        CardView.addShadow(to: self.shadowContainer)
//        CardView.addRoundedCorners(to: self.container)

        self.todayCountLabel.backgroundColor = Brand.default.colors.secondary
        self.nextCountLabel.backgroundColor = Brand.default.colors.secondary
        self.allCountLabel.backgroundColor = Brand.default.colors.secondary

        for pill in self.pills {
            pill.backgroundColor = Brand.default.colors.secondary
            pill.layer.cornerRadius = pill.layer.bounds.height / 2
            pill.layer.masksToBounds = true
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        CardView.updateClippingPath(of: self.container)
//        CardView.updateShadowPath(of: self.shadowContainer)
//    }

    func loadData() {
        self.loadCountData(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1), into: self.todayCountLabel)
        self.loadCountData(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7), into: self.nextCountLabel)
        self.loadCountData(for: CourseDateHelper.FetchRequest.allCourseDates, into: self.allCountLabel)
    }

    private func loadCountData(for fetchRequest: NSFetchRequest<CourseDate>, into label: UILabel) {
        if let count = try? CoreDataHelper.viewContext.count(for: fetchRequest) {
            label.text = String(count)
        } else {
            label.text = "-"
        }
    }

    @objc func tappedOnView() {
        self.delegate?.openCourseDateList()
    }

}
