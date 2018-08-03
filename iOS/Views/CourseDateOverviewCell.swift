//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseDateOverviewCell: UITableViewCell {

    @IBOutlet private weak var overviewContainer: UIView!
    @IBOutlet private weak var todayCountLabel: UILabel!
    @IBOutlet private weak var sevenDaysCountLabel: UILabel!
    @IBOutlet private weak var allCountLabel: UILabel!
    @IBOutlet private weak var nextDateContainer: UIView!
    @IBOutlet private weak var nextDateStackView: UIStackView!
    @IBOutlet private weak var nextDateDateLabel: UILabel!
    @IBOutlet private weak var nextDateCourseLabel: UILabel!
    @IBOutlet private weak var nextDateTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyCardLook(to: self.overviewContainer)
        self.applyCardLook(to: self.nextDateContainer)
        self.nextDateCourseLabel.textColor = Brand.default.colors.secondary
        self.nextDateStackView.isHidden = true
    }

    private func applyCardLook(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 6.0
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 8.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    private func loadOverviewData() {
        self.loadCountData(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1), into: self.todayCountLabel)
        self.loadCountData(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7), into: self.sevenDaysCountLabel)
        self.loadCountData(for: CourseDateHelper.FetchRequest.allCourseDates, into: self.allCountLabel)
    }

    private func loadCountData(for fetchRequest: NSFetchRequest<CourseDate>, into label: UILabel) {
        if let count = try? CoreDataHelper.viewContext.count(for: fetchRequest) {
            label.text = String(count)
        } else {
            label.text = "?"
        }
    }

    private func loadNextDateData() {
        if let courseDate = CoreDataHelper.viewContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value {
            self.nextDateDateLabel.text = courseDate.defaultDateString
            self.nextDateCourseLabel.text = courseDate.course?.title
            self.nextDateTitleLabel.text = courseDate.contextAwareTtitle
            self.nextDateStackView.isHidden = false
        } else {
            self.nextDateStackView.isHidden = true
        }
    }

    func loadData() {
        self.loadOverviewData()
        self.loadNextDateData()
    }

}
