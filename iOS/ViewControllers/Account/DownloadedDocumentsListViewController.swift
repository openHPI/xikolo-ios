//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedDocumentsListViewController: UITableViewController {

    @IBOutlet private weak var selectAllBarButton: UIBarButtonItem!
    @IBOutlet private weak var deleteBarButton: UIBarButtonItem!

    private var courseId: String!
    private var dataSource: CoreDataTableViewDataSource<DownloadedDocumentsListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = DownloadedContentListViewController.DownloadType.document.title
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        guard let course = self.fetchCourse(withID: self.courseId) else { return }
        let request = DocumentLocalizationHelper.FetchRequest.downloadedDocumentLocalizations(forCourse: course)

        let reuseIdentifier = R.reuseIdentifier.downloadItemCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

    }

    func configure(forCourseWithId courseId: String) {
        self.courseId = courseId
    }

    func fetchCourse(withID id: String) -> Course? {
        let request = CourseHelper.FetchRequest.course(withSlugOrId: id)
        return CoreDataHelper.viewContext.fetchSingle(request).value
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.updateToolBar()
        self.navigationController?.setToolbarHidden(!editing, animated: animated)
        self.navigationItem.setHidesBackButton(editing, animated: animated)
    }

    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        super.tableView(tableView, willBeginEditingRowAt: indexPath)
        self.navigationController?.setToolbarHidden(true, animated: trueUnlessReduceMotionEnabled)
        self.navigationItem.setHidesBackButton(false, animated: trueUnlessReduceMotionEnabled)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isEditing else { return }
        self.updateToolBar()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard self.isEditing else { return }
        self.updateToolBar()
    }

    private func updateToolBar() {
        var title: String {
            let allRowsSelected = self.allIndexPaths.count == self.tableView.indexPathsForSelectedRows?.count
            if allRowsSelected {
                return NSLocalizedString("settings.downloads.toolbar.deselect all", comment: "button title for deselecting all rows")
            } else {
                return NSLocalizedString("settings.downloads.toolbar.select all", comment: "button title for selecting all rows")
            }
        }

        self.selectAllBarButton.title = title
        self.deleteBarButton.isEnabled = !(self.tableView.indexPathsForSelectedRows?.isEmpty ?? true)
    }

    private var allIndexPaths: [IndexPath] {
        return (0..<self.tableView.numberOfSections).flatMap { section in
            return (0..<self.tableView.numberOfRows(inSection: section)).map { row in
                return IndexPath(row: row, section: section)
            }
        }
    }

    @IBAction private func selectMultiple() {
        let allIndexPaths = self.allIndexPaths
        let allRowsSelected = allIndexPaths.count == self.tableView.indexPathsForSelectedRows?.count
        self.tableView.beginUpdates()

        if allRowsSelected {
            allIndexPaths.forEach { indexPath in
                self.tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
            }
        } else {
            allIndexPaths.forEach { indexPath in
                self.tableView.selectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled, scrollPosition: .none)
            }
        }

        self.tableView.endUpdates()
        self.updateToolBar()
    }

    @IBAction private func deleteSelectedIndexPaths() {
        guard let indexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }

        let alert = UIAlertController { [weak self] _ in
            guard let self = self else { return }

            for indexPath in indexPaths {
                let object = self.dataSource.object(at: indexPath)
                DocumentsPersistenceManager.shared.deleteDownload(for: object)
            }

            self.setEditing(false, animated: trueUnlessReduceMotionEnabled)
        }

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

}

extension DownloadedDocumentsListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: DocumentLocalization) {
        cell.textLabel?.text = object.languageCode
        cell.detailTextLabel?.text = DocumentsPersistenceManager.shared.formattedFileSize(for: object)
    }

    func titleForDefaultHeader(forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        guard let dataSource = self.dataSource else { return nil }
        return dataSource.object(at: indexPath).document.title
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }

    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentLocalization = self.dataSource.object(at: indexPath)
            DocumentsPersistenceManager.shared.deleteDownload(for: documentLocalization)
        }
    }

}
