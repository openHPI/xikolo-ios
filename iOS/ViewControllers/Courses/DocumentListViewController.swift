//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import DZNEmptyDataSet
import UIKit

class DocumentListViewController: UITableViewController {

    var course: Course!

    var resultsController: NSFetchedResultsController<DocumentLocalization>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<DocumentLocalization>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // register custom section header view
//        self.tableView.register(R.nib.courseItemHeader(), forHeaderFooterViewReuseIdentifier: R.nib.courseItemHeader.name)

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.documentCell.identifier
        let request = DocumentLocalizationHelper.FetchRequest.documentLocalizations(forCourse: course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title") // must be the first sort descriptor
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: reuseIdentifier)

        let configuration = DocumentListViewConfiguration().wrapped
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        self.refresh()

        do {
            try resultsController.performFetch()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }

        self.tableView.reloadData()

        self.setupEmptyState()
    }

    func setupEmptyState() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadEmptyDataSet()
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        DocumentHelper.syncDocuments(forCourse: self.course).onComplete { _ in
            stopRefreshControl()
        }
    }
}

extension DocumentListViewController { // TableViewDelegate

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseItemHeader.name) as? CourseItemHeader else {
//            return nil
//        }
//
//        let visualIndexPath = IndexPath(row: 0, section: section)
//        guard let (controller, indexPath) = self.resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: visualIndexPath) else {
//            return nil
//        }
//
//        guard let section = controller.object(at: indexPath).section else {
//            return nil
//        }
//
//        header.configure(for: section, inOfflineMode: self.inOfflineMode)
//        header.delegate = self
//
//        return header
//    }

//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }

}

class DocumentListViewConfiguration: TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<DocumentLocalization>, indexPath: IndexPath) {
//        let cell = cell.require(toHaveType: DocumentCell.self, hint: "CourseItemListViewController requires cell of type CourseItemCell")
        let item = controller.object(at: indexPath)
//        cell.configure(for: item)
        cell.textLabel?.text = item.title
    }

    func titleForDefaultHeader(forController controller: NSFetchedResultsController<DocumentLocalization>, forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        return controller.object(at: indexPath).document.title
    }

}

extension DocumentListViewController: CourseContentViewController {

    func configure(for course: Course) {
        self.course = course
    }

}

extension DocumentListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.course-documents.title", comment: "title for empty course documents list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.course-documents.description",
                                            comment: "description for empty course documents list")
        return NSAttributedString(string: description)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.refresh()
    }

}
