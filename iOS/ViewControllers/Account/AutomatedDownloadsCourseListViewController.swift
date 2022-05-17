//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

@available(iOS 13, *)
class AutomatedDownloadsCourseListViewController: UITableViewController {

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
            let reuseIdentifier = self.cellReuseIdentifier(for: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
            let course = resultsController.object(at: adjustedIndexPath)
            cell.textLabel?.text = course.title
            cell.detailTextLabel?.text = course.automatedDownloadSettings?.newContentAction.title // TODO: all values
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }()

    private let defaultCellReuseIdentifier = "DefaultCell"
    private let subtitleCellReuseIdentifier = "SubtitleCell"

    init() {
        super.init(style: .insetGrouped)
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.defaultCellReuseIdentifier)
        self.tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: self.subtitleCellReuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Content Notifications"
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

    private func cellReuseIdentifier(for indexPath: IndexPath) -> String {
        if self.activeCoursesFetchedResultsController.fetchedObjects?.isEmpty ?? true {
            return self.defaultCellReuseIdentifier
        }

        return indexPath.section == 0 ? self.subtitleCellReuseIdentifier : self.defaultCellReuseIdentifier
    }

}

@available(iOS 13, *)
extension AutomatedDownloadsCourseListViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let changes = snapshot as NSDiffableDataSourceSnapshot<String, NSObject>

        let currentSnapshot = self.dataSource.snapshot()

        let section1 = "Activated For" // TODO: localize
        let section2 = "Available For"

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
        return "No Courses available"
    }

    var emptyStateDetailText: String? {
        return "Automated downloads are only available during the course period for courses you enrolled to."
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
    }

}
