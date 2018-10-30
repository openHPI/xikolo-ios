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

    var inOfflineMode = ReachabilityHelper.connection == .none {
        didSet {
            if oldValue != self.inOfflineMode {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44

        // register custom section header view
        self.tableView.register(UINib(resource: R.nib.documentHeader), forHeaderFooterViewReuseIdentifier: R.nib.documentHeader.name)

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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)
    }

    func setupEmptyState() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.reloadEmptyDataSet()
    }

    @objc func reachabilityChanged() {
        self.inOfflineMode = ReachabilityHelper.connection == .none
    }

}

extension DocumentListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let documentLocalization = self.dataSource.object(at: indexPath)

        guard let url = DocumentsPersistenceManager.shared.localFileLocation(for: documentLocalization) ?? documentLocalization.fileURL else { return }

        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        let filename = [documentLocalization.document.title, documentLocalization.title].compactMap { $0 }.joined(separator: " - ")
        pdfViewController.configure(for: url, filename: filename)
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.documentHeader.name) as? DocumentHeader else {
            return nil
        }

        let indexPath = IndexPath(row: 0, section: section)
        let document = self.dataSource.object(at: indexPath).document
        header.configure(for: document)

        return header
    }

}

extension DocumentListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: DocumentLocalizationCell, for object: DocumentLocalization) {
        cell.delegate = self
        cell.configure(for: object)
    }

}

extension DocumentListViewController: CourseAreaViewController {

    var area: CourseArea {
        return .documents
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.course = course
    }

}

extension DocumentListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return DocumentHelper.syncDocuments(forCourse: self.course).asVoid()
    }

}

extension DocumentListViewController: UserActionsDelegate {

    func showAlert(with actions: [UIAlertAction], title: String?, message: String?, on anchor: UIView) {
        guard !actions.isEmpty else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = anchor
        alert.popoverPresentationController?.sourceRect = anchor.bounds.insetBy(dx: -4, dy: -4)
        alert.popoverPresentationController?.permittedArrowDirections = [.left, .right]

        for action in actions {
            alert.addAction(action)
        }

        alert.addCancelAction()

        self.present(alert, animated: true)
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
