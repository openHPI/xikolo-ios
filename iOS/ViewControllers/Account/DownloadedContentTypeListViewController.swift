//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedContentTypeListViewController<Configuration: DownloadedContentTypeListConfiguraton>: UITableViewController {

    typealias Resource = Configuration.ManagerConfiguration.Resource

    private let cellReuseIdentifier = "downloadedItem"

    private lazy var selectBarButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(selectMultiple))
    private lazy var deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedIndexPaths))

    private var courseId: String
    private var dataSource: CoreDataTableViewDataSource<DownloadedContentTypeListViewController>!

    init(forCourseId courseId: String, configuration: Configuration.Type) {
        self.courseId = courseId

        if #available(iOS 13, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }

        // Workaround for hiding additional top offset of the table view caused by groped style
        // See: https://stackoverflow.com/a/18938763/7414898
        let frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 0.001)
        self.tableView.tableHeaderView = UIView(frame: frame)

        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Configuration.navigationTitle
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.toolbarItems = [
            self.selectBarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            self.deleteBarButton,
        ]

        guard let course = self.fetchCourse(withID: self.courseId) else { return }
        let resultsController = Configuration.resultsController(for: course)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: self.cellReuseIdentifier,
                                                      delegate: self)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.updateToolBarButtons()
        self.navigationController?.setToolbarHidden(!editing, animated: animated)
        self.navigationItem.setHidesBackButton(editing, animated: animated)

        if !editing {
            for cell in self.tableView.visibleCells {
                cell.selectedBackgroundView = nil
            }
        }
    }

    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        super.tableView(tableView, willBeginEditingRowAt: indexPath)
        self.navigationController?.setToolbarHidden(true, animated: trueUnlessReduceMotionEnabled)
        self.navigationItem.setHidesBackButton(false, animated: trueUnlessReduceMotionEnabled)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isEditing {
            self.updateToolBarButtons()
            tableView.cellForRow(at: indexPath)?.selectedBackgroundView = UIView(backgroundColor: ColorCompatibility.secondarySystemGroupedBackground)
        } else {
            let object = self.dataSource.object(at: indexPath)
            Configuration.show(object, with: self.appNavigator)
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard self.isEditing else { return }
        self.updateToolBarButtons()
        tableView.cellForRow(at: indexPath)?.selectedBackgroundView = nil
    }

    override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        self.isEditing = true
    }

    private func fetchCourse(withID id: String) -> Course? {
        let request = CourseHelper.FetchRequest.course(withSlugOrId: id)
        return CoreDataHelper.viewContext.fetchSingle(request).value
    }

    private func updateToolBarButtons() {
        var title: String {
            let allRowsSelected = self.allIndexPaths.count == self.tableView.indexPathsForSelectedRows?.count
            if allRowsSelected {
                return NSLocalizedString("global.list.selection.deselect all", comment: "Title for button for deselecting all items in a list")
            } else {
                return NSLocalizedString("global.list.selection.select all", comment: "Title for button for selecting all items in a list")
            }
        }

        self.selectBarButton.title = title
        self.deleteBarButton.isEnabled = !(self.tableView.indexPathsForSelectedRows?.isEmpty ?? true)
    }

    private var allIndexPaths: [IndexPath] {
        return (0..<self.tableView.numberOfSections).flatMap { section in
            return (0..<self.tableView.numberOfRows(inSection: section)).map { row in
                return IndexPath(row: row, section: section)
            }
        }
    }

    @objc private func selectMultiple() {
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
        self.updateToolBarButtons()
    }

    @objc private func deleteSelectedIndexPaths() {
        guard let indexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }

        let alert = UIAlertController { [weak self] _ in
            guard let self = self else { return }

            for indexPath in indexPaths {
                let object = self.dataSource.object(at: indexPath)
                Configuration.persistenceManager.deleteDownload(for: object)
            }

            self.setEditing(false, animated: trueUnlessReduceMotionEnabled)
        }

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

}

extension DownloadedContentTypeListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: Resource) {
        cell.textLabel?.text = object[keyPath: Configuration.cellTitleKeyPath]
        cell.detailTextLabel?.text = Configuration.persistenceManager.formattedFileSize(for: object)
        cell.accessoryType = .disclosureIndicator
        cell.selectedBackgroundView = self.isEditing ? UIView(backgroundColor: ColorCompatibility.secondarySystemGroupedBackground) : nil
    }

    func titleForDefaultHeader(forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        guard let dataSource = self.dataSource else { return nil }
        return dataSource.object(at: indexPath)[keyPath: Configuration.sectionTitleKeyPath]
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }

    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = self.dataSource.object(at: indexPath)
            Configuration.persistenceManager.deleteDownload(for: object)
        }
    }

}
