//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseDateOverviewViewController: UIViewController {

    @IBOutlet private weak var summaryContainer: UIView!
    @IBOutlet private weak var todayCountLabel: UILabel!
    @IBOutlet private weak var nextCountLabel: UILabel!
    @IBOutlet private weak var allCountLabel: UILabel!
    @IBOutlet private var summaryWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var nextUpView: UIView!
    @IBOutlet private weak var nextUpContainer: UIView!
    @IBOutlet private weak var nextUpImageView: UIImageView!
    @IBOutlet private weak var relativeDateTimeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private var nextUpWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var equalTitleWrapperHeightConstraint: NSLayoutConstraint!

    private lazy var courseDateFormatter: DateFormatter = {
        return DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)
    }()

    private lazy var relativeCourseDateFormatter: DateFormatter = {
        let formatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateWidthConstraints()
        self.summaryContainer.layer.roundCorners(for: .default, masksToBounds: false)
        self.nextUpContainer.layer.roundCorners(for: .default, masksToBounds: false)

        self.summaryContainer.addDefaultPointerInteraction()
        self.nextUpContainer.addDefaultPointerInteraction()

        self.courseLabel.textColor = Brand.default.colors.secondary
        self.nextUpView.isHidden = true
        self.nextUpContainer.isHidden = true
        self.equalTitleWrapperHeightConstraint.isActive = false

        self.loadData()

        let summaryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAllCourseDates))
        self.summaryContainer.addGestureRecognizer(summaryGestureRecognizer)

        let nextUpGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCourseForNextCourseDate))
        self.nextUpContainer.addGestureRecognizer(nextUpGestureRecognizer)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateWidthConstraints()
    }

    func loadData() {
        self.todayCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1))
        self.nextCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7))
        self.allCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.allCourseDates)

        if let courseDate = CoreDataHelper.viewContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value {
            self.courseLabel.text = courseDate.course?.title
            self.titleLabel.text = courseDate.contextAwareTitle
            self.nextUpView.isHidden = false
            self.nextUpContainer.isHidden = false
            self.equalTitleWrapperHeightConstraint.isActive = true

            if #available(iOS 13, *) {
                self.nextUpImageView.image = R.image.calendarLarge()
                self.relativeDateTimeLabel.text = courseDate.relativeDateTime
                self.dateLabel.text = courseDate.date.map(self.courseDateFormatter.string(from:))
            } else {
                self.nextUpImageView.image = R.image.calendar()
                self.relativeDateTimeLabel.text = nil
                self.dateLabel.text = courseDate.date.map(self.relativeCourseDateFormatter.string(from:))
            }
        } else {
            self.nextUpView.isHidden = true
            self.nextUpContainer.isHidden = true
            self.equalTitleWrapperHeightConstraint.isActive = false
        }
    }

    private func formattedItemCount(for fetchRequest: NSFetchRequest<CourseDate>) -> String {
        if let count = try? CoreDataHelper.viewContext.count(for: fetchRequest) {
            return String(count)
        } else {
            return "-"
        }
    }

    private func updateWidthConstraints() {
        let courseCellWidth = CourseCell.minimalWidthInOverviewList(for: self.traitCollection)
        let availableWidth = self.view.bounds.width - self.view.layoutMargins.left - self.view.layoutMargins.right + 2 * CourseCell.cardInset
        let itemsPerRow = floor(availableWidth / courseCellWidth)
        let cellWidth = availableWidth / itemsPerRow

        self.summaryWidthConstraint.constant = cellWidth - 2 * CourseCell.cardInset
        self.nextUpWidthConstraint.constant = cellWidth - 2 * CourseCell.cardInset
    }

    @objc private func showAllCourseDates() {
        self.performSegue(withIdentifier: R.segue.courseDateOverviewViewController.showCourseDates, sender: nil)
    }

    @objc private func showCourseForNextCourseDate() {
        guard let course = CoreDataHelper.viewContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value?.course else { return }
        self.appNavigator?.show(course: course)
    }

    @objc private func coreDataChange(notification: Notification) {
        let courseDatesChanged = notification.includesChanges(for: CourseDate.self)
        let courseRefreshed = notification.includesChanges(for: Course.self, key: .refreshed)
        let enrollmentRefreshed = notification.includesChanges(for: Enrollment.self, key: .refreshed)

        if courseDatesChanged || courseRefreshed || enrollmentRefreshed {
            self.loadData()
        }
    }

}
