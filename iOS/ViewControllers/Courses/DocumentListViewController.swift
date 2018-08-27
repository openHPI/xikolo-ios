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

    var resultsController: NSFetchedResultsController<DocumentLocalization>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<DocumentLocalization>!

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
        self.tableView.register(R.nib.documentHeader(), forHeaderFooterViewReuseIdentifier: R.nib.documentHeader.name)

        self.addRefreshControl()

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.documentCell.identifier
        let request = DocumentLocalizationHelper.FetchRequest.publicDocumentLocalizations(forCourse: course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title") // must be the first sort descriptor
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: reuseIdentifier)

        let configuration = DocumentListViewConfiguration(listController: self).wrapped
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
        guard let (controller, realIndexPath) = self.resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath) else {
            return
        }

        let documentLocaliztion = controller.object(at: realIndexPath)

        guard let url = DocumentsPersistenceManager.shared.localFileLocation(for: documentLocaliztion) ?? documentLocaliztion.fileURL else { return }

        let pdfViewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        pdfViewController.url = url
        self.navigationController?.pushViewController(pdfViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.documentHeader.name) as? DocumentHeader else {
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

    let listController: DocumentListViewController

    init(listController: DocumentListViewController) {
        self.listController = listController
    }

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<DocumentLocalization>, indexPath: IndexPath) {
        let item = controller.object(at: indexPath)
        let localizationCell = cell as! DocumentLocalizationCell
        localizationCell.delegate = self.listController
        localizationCell.configure(for: item)
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

extension DocumentListViewController: UserActionsDelegate {

    func showAlert(with actions: [UIAlertAction], title: String?, message: String?, on anchor: UIView) {
        guard !actions.isEmpty else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = anchor
        alert.popoverPresentationController?.sourceRect = anchor.bounds.insetBy(dx: -4, dy: -4)

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
