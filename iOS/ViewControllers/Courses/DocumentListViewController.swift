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

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44

        // register custom section header view
        self.tableView.register(R.nib.courseDocumentHeader(), forHeaderFooterViewReuseIdentifier: R.nib.courseDocumentHeader.name)

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let (controller, realIndexPath) = self.resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath) else {
            return
        }

        let documentLocaliztion = controller.object(at: realIndexPath)

        guard let url = documentLocaliztion.fileURL else { return }

        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        pdfViewController.url = url
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseDocumentHeader.name) as? CourseDocumentHeader else {
            return nil
        }

        let visualIndexPath = IndexPath(row: 0, section: section)
        guard let (controller, indexPath) = self.resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: visualIndexPath) else {
            return nil
        }

        let document = controller.object(at: indexPath).document
        header.configure(for: document)

        return header
    }

}

class DocumentListViewConfiguration: TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<DocumentLocalization>, indexPath: IndexPath) {
        let item = controller.object(at: indexPath)
        cell.textLabel?.text = item.languageCode
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
