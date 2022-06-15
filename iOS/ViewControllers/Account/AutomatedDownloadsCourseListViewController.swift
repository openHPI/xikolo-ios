//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

@available(iOS 13, *)
class AutomatedDownloadsCourseListViewController: UITableViewController { // swiftlint:disable:this type_name

    lazy var activeCoursesFetchedResultsController: NSFetchedResultsController<Course> = {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let fetchedResultsController = CoreDataHelper.createResultsController(fetchRequest, sectionNameKeyPath: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    lazy var inactiveCoursesFetchedResultsController: NSFetchedResultsController<Course> = {
        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let fetchedResultsController = CoreDataHelper.createResultsController(fetchRequest, sectionNameKeyPath: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    lazy var dataSource: UITableViewDiffableDataSource = {
        return HeaderTableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, _ -> UITableViewCell? in
            let resultsController = self.resultController(for: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: self.subtitleCellReuseIdentifier, for: indexPath)
            let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
            let course = resultsController.object(at: adjustedIndexPath)
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

        try? self.activeCoursesFetchedResultsController.performFetch()
        try? self.inactiveCoursesFetchedResultsController.performFetch()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resultsController = self.resultController(for: indexPath)
        let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
        let course = resultsController.object(at: adjustedIndexPath)
        let viewController = AutomatedDownloadsSettingsViewController(course: course)
        self.show(viewController, sender: self)
    }

    private func resultController(for indexPath: IndexPath) -> NSFetchedResultsController<Course> {
        if self.activeCoursesFetchedResultsController.fetchedObjects?.isEmpty ?? true {
            return self.inactiveCoursesFetchedResultsController
        }

        return indexPath.section == 0 ? self.activeCoursesFetchedResultsController : self.inactiveCoursesFetchedResultsController
    }

}

@available(iOS 13, *)
extension AutomatedDownloadsCourseListViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let changes = snapshot as NSDiffableDataSourceSnapshot<String, NSObject>

        let currentSnapshot = self.dataSource.snapshot()

        let section1 = NSLocalizedString("automated-downloads.course-list.section.title.activated for",
                                         comment: "Section title in course list for activated automated downloads")
        let section2 = NSLocalizedString("automated-downloads.course-list.section.title.available for",
                                         comment: "Section title in course list for available automated downloads")

        var snapshot = NSDiffableDataSourceSnapshot<String, NSObject>()

        if controller == self.activeCoursesFetchedResultsController {
            if !changes.itemIdentifiers.isEmpty {
                snapshot.appendSections([section1])
                snapshot.appendItems(changes.itemIdentifiers, toSection: section1)
            }

            if currentSnapshot.sectionIdentifiers.contains(section2) {
                snapshot.appendSections([section2])
                var itemsInOtherSection = currentSnapshot.itemIdentifiers(inSection: section2)
                itemsInOtherSection.removeAll { changes.itemIdentifiers.contains($0) }
                snapshot.appendItems(itemsInOtherSection, toSection: section2)
            }
        } else {
            if currentSnapshot.sectionIdentifiers.contains(section1) {
                snapshot.appendSections([section1])
                var itemsInOtherSection = currentSnapshot.itemIdentifiers(inSection: section1)
                itemsInOtherSection.removeAll { changes.itemIdentifiers.contains($0) }
                snapshot.appendItems(itemsInOtherSection, toSection: section1)
            }

            if !changes.itemIdentifiers.isEmpty {
                snapshot.appendSections([section2])
                snapshot.appendItems(changes.itemIdentifiers, toSection: section2)
            }
        }

        self.dataSource.apply(snapshot, animatingDifferences: false)
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
