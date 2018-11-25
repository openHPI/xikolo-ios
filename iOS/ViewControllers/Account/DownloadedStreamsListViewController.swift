//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedStreamsListViewController: UITableViewController {

    @IBOutlet private weak var selectAllBarButton: UIBarButtonItem!
    @IBOutlet private weak var deleteBarButton: UIBarButtonItem!

    private var courseId: String!
    private var dataSource: CoreDataTableViewDataSource<DownloadedStreamsListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = DownloadedContentListViewController.DownloadType.video.title
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        let request = VideoHelper.FetchRequest.videosWithDownloadedStream(inCourse: self.courseId)
        let reuseIdentifier = R.reuseIdentifier.downloadItemCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)
    }

    func configure(forCourseWithId courseId: String) {
        self.courseId = courseId
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
                StreamPersistenceManager.shared.deleteDownload(for: object)
            }

            self.setEditing(false, animated: trueUnlessReduceMotionEnabled)
        }

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

}

extension DownloadedStreamsListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: Video) {
        cell.textLabel?.text = object.item?.title
        cell.detailTextLabel?.text = StreamPersistenceManager.shared.formattedFileSize(for: object)
    }

    func titleForDefaultHeader(forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        guard let dataSource = self.dataSource else { return nil }
        return dataSource.object(at: indexPath).item?.section?.title
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }

    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = self.dataSource.object(at: indexPath)
            StreamPersistenceManager.shared.deleteDownload(for: video)
        }
    }

}
