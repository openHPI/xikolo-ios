//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

@available(iOS 13, *)
class AutomatedDownloadsCourseListViewController: UITableViewController { // swiftlint:disable:this type_name

    private lazy var activeCourses: [Course] = {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let result = CoreDataHelper.viewContext.fetchMultiple(fetchRequest)
        return result.value ?? []
    }()

    private lazy var inactiveCourses: [Course] = {
        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let result = CoreDataHelper.viewContext.fetchMultiple(fetchRequest)
        return result.value?.filter { FeatureHelper.hasFeature(.newContentNotification, for: $0) } ?? []
    }()

    lazy var dataSource: UITableViewDiffableDataSource = {
        return StringSectionTableViewDiffableDataSource<Course>(tableView: self.tableView) { tableView, indexPath, course -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.subtitleCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = course.title
            cell.detailTextLabel?.text = CoursePeriodFormatter.string(from: course)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }()

    private let subtitleCellReuseIdentifier = "SubtitleCell"

    init() {
        super.init(style: .insetGrouped)
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: self.subtitleCellReuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("automated-downloads.course-list.title", comment: "Title for course list for automated downloads")
        self.tableView.dataSource = self.dataSource

        self.setupEmptyState()

        let section1 = NSLocalizedString("automated-downloads.course-list.section.title.activated for",
                                         comment: "Section title in course list for activated automated downloads")
        let section2 = NSLocalizedString("automated-downloads.course-list.section.title.available for",
                                         comment: "Section title in course list for available automated downloads")

        var snapshot = self.dataSource.snapshot()

        if !self.activeCourses.isEmpty {
            snapshot.appendSections([section1])
            snapshot.appendItems(self.activeCourses, toSection: section1)
        }

        if !self.inactiveCourses.isEmpty {
            snapshot.appendSections([section2])
            snapshot.appendItems(self.inactiveCourses, toSection: section2)
        }

        self.dataSource.apply(snapshot)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courses = indexPath.section == 0 && !self.activeCourses.isEmpty ? self.activeCourses : self.inactiveCourses
        let course = courses[indexPath.row]
        let viewController = AutomatedDownloadsSettingsViewController(course: course)
        self.show(viewController, sender: self)
    }

}

@available(iOS 13, *)
extension AutomatedDownloadsCourseListViewController: EmptyStateDataSource {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.automated-downloads.course-list.title", comment: "title for empty course list for automated downloads")
    }

    var emptyStateDetailText: String? {
        return NSLocalizedString("empty-view.automated-downloads.course-list.explanation", comment: "explanation for empty course list for automated downloads")
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
    }

}
