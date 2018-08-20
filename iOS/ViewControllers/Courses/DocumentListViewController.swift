//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import DZNEmptyDataSet
import UIKit

class DocumentListViewController: UITableViewController {

    var course: Course!

    private var dataSource: CoreDataTableViewDataSource<DocumentListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44

        // register custom section header view
        self.tableView.register(R.nib.courseDocumentHeader(), forHeaderFooterViewReuseIdentifier: R.nib.courseDocumentHeader.name)

        self.addRefreshControl()

        // setup table view data
        let request = DocumentLocalizationHelper.FetchRequest.publicDocumentLocalizations(forCourse: course)
        let reuseIdentifier = R.reuseIdentifier.documentCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title") // must be the first sort descriptor
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.refresh()

        self.tableView.reloadData()

        // needs to be called in order to display the header view correctly
        self.tableView.layoutIfNeeded()

        self.setupEmptyState()
    }

    func setupEmptyState() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadEmptyDataSet()
    }

}

extension DocumentListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let documentLocaliztion = self.dataSource.object(at: indexPath)

        guard let url = documentLocaliztion.fileURL else { return }

        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        pdfViewController.url = url
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseDocumentHeader.name) as? CourseDocumentHeader else {
            return nil
        }

        let indexPath = IndexPath(row: 0, section: section)
        let document = self.dataSource.object(at: indexPath).document
        header.configure(for: document)

        return header
    }

}

extension DocumentListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: DocumentLocalization) {
        cell.textLabel?.text = object.languageCode
    }

}

extension DocumentListViewController: CourseAreaViewController {

    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate) {
        self.course = course
    }

}

extension DocumentListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return DocumentHelper.syncDocuments(forCourse: self.course).asVoid()
    }

}

extension DocumentListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.course-documents.title", comment: "title for empty course documents list")
        return NSAttributedString(string: title)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.refresh()
    }

}
