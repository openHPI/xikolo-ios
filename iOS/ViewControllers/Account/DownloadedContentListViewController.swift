//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import Foundation
import UIKit

class DownloadedContentListViewController: UITableViewController {

    private static let timeEffortFormatter: DateComponentsFormatter = {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = Locale.autoupdatingCurrent
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    @IBOutlet private weak var totalFileSizeLabel: UILabel!
    @IBOutlet private weak var selectAllBarButton: UIBarButtonItem!
    @IBOutlet private weak var deleteBarButton: UIBarButtonItem!

    struct CourseDownload {
        var id: String
        var title: String
        var byteCounts: [DownloadedContentHelper.ContentType: UInt64] = [:]
        var timeEffort: TimeInterval = 0

        init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    private var courseDownloads: [CourseDownload] = [] {
        didSet {
            let isEditing = self.isEditing && !self.courseDownloads.isEmpty
            self.navigationController?.setToolbarHidden(!isEditing, animated: trueUnlessReduceMotionEnabled)
            self.navigationItem.setHidesBackButton(isEditing, animated: trueUnlessReduceMotionEnabled)

            self.updateToolBarButtons()
            self.updateTotalFileSizeLabel()

            self.navigationItem.rightBarButtonItem = self.courseDownloads.isEmpty ? nil : self.editButtonItem
            self.tableView.reloadData()
        }
    }

    private let subMenuCellReuseIdentifier = "submenu"
    private let infoCellReuseIdentifier = "infocell"

    lazy var hasAdditionalSection: Bool = {
        if #available(iOS 13, *) {
            return true
        } else {
            return false
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(DefaultTableViewCell.self, forCellReuseIdentifier: self.subMenuCellReuseIdentifier)
        self.tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: self.infoCellReuseIdentifier)

        self.setupEmptyState()
        self.refresh()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.tableView.resizeTableHeaderView()
        }
    }

    @discardableResult
    private func refresh() -> Future<[DownloadedContentHelper.DownloadContent], XikoloError> {
        return DownloadedContentHelper.downloadedContentForAllCourses().onSuccess { downloadItems in
            var downloadedCourseList: [String: CourseDownload] = [:]

            for downloadItem in downloadItems {
                let courseId = downloadItem.courseID
                var courseDownload = downloadedCourseList[courseId, default: CourseDownload(id: courseId, title: downloadItem.courseTitle ?? "")]
                courseDownload.byteCounts[downloadItem.contentType, default: 0] += downloadItem.fileSize ?? 0
                courseDownload.timeEffort += ceil(TimeInterval(downloadItem.timeEffort ?? 0) / 60) * 60 // round up to full minutes
                downloadedCourseList[downloadItem.courseID] = courseDownload
            }

            self.courseDownloads = downloadedCourseList.values.sorted { $0.title < $1.title }
        }.onFailure { error in
            logger.error(error.localizedDescription)
        }
    }

    private func updateTotalFileSizeLabel() {
        let fileSize = self.courseDownloads.map(self.aggregatedFileSize).reduce(0, +)
        let format = NSLocalizedString("settings.downloads.total size: %@", comment: "total size label")
        let formattedFileSize = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
        self.totalFileSizeLabel.text = String.localizedStringWithFormat(format, formattedFileSize)
        self.tableView.tableHeaderView?.isHidden = self.courseDownloads.isEmpty
        self.tableView.resizeTableHeaderView()
    }

    private func aggregatedFileSize(for courseDownload: CourseDownload) -> UInt64 {
        return courseDownload.byteCounts.values.reduce(0, +)
    }

    @objc private func coreDataChange(notification: Notification) {
        let containsVideoDeletion = notification.includesChanges(for: Video.self, keys: [.deleted, .refreshed])
        let containsDocumentDeletion = notification.includesChanges(for: DocumentLocalization.self, keys: [.deleted, .refreshed])
        if containsVideoDeletion || containsDocumentDeletion {
            self.refresh()
        }
    }

}

extension DownloadedContentListViewController { // Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = max(self.courseDownloads.count, 1)
        sectionCount += self.hasAdditionalSection ? 1 : 0
        return sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hasAdditionalSection, section == 0 { return 1 }
        if self.courseDownloads.isEmpty { return 1 }
        let section = self.hasAdditionalSection ? section - 1 : section
        return self.courseDownloads[section].byteCounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.hasAdditionalSection, indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.subMenuCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = "Manage Automated Downloads" // TODO: localize
            cell.accessoryType = .disclosureIndicator
            cell.selectedBackgroundView = self.isEditing ? UIView(backgroundColor: ColorCompatibility.secondarySystemGroupedBackground) : nil
            return cell
        }

        if self.courseDownloads.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.infoCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("empty-view.account.download.no-downloads.title", comment: "title for empty download list")
            cell.detailTextLabel?.text = NSLocalizedString("empty-view.account.download.no-downloads.description", comment: "description for empty download list")
            return cell
        }

        let section = self.hasAdditionalSection ? indexPath.section - 1 : indexPath.section
        let adjustedIndexPath = IndexPath(row: indexPath.row, section: section)

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.downloadTypeCell, for: indexPath).require()
        let downloadType = self.downloadType(for: adjustedIndexPath)
        let byteCount = self.courseDownloads[adjustedIndexPath.section].byteCounts[downloadType]
        cell.textLabel?.text = downloadType.title
        cell.detailTextLabel?.text = byteCount.flatMap { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .file) }
        cell.selectedBackgroundView = self.isEditing ? UIView(backgroundColor: ColorCompatibility.secondarySystemGroupedBackground) : nil
        return cell
    }

    private func downloadType(for indexPath: IndexPath) -> DownloadedContentHelper.ContentType {
        let byteCountKeys = self.courseDownloads[indexPath.section].byteCounts.keys
        return DownloadedContentHelper.ContentType.allCases.filter(byteCountKeys.contains)[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.hasAdditionalSection, section == 0 { return nil }
        if self.courseDownloads.isEmpty { return nil }
        let section = self.hasAdditionalSection ? section - 1 : section
        return self.courseDownloads[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if self.hasAdditionalSection, section == 0 { return nil }
        if self.courseDownloads.isEmpty { return nil }

        let section = self.hasAdditionalSection ? section - 1 : section

        let timeEffort = self.courseDownloads[section].timeEffort

        guard timeEffort > 0 else {
            return nil
        }

        let formattedTimeEffort = Self.timeEffortFormatter.string(from: timeEffort)
        let format = NSLocalizedString("settings.downloads.estimated time effort: %@", comment: "label for estimated time effort of downloaded course content")
        return formattedTimeEffort.map { String.localizedStringWithFormat(format, $0) }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.hasAdditionalSection, indexPath.section == 0 {
            if #available(iOS 13, *) {
                let viewController = AutomatedDownloadsCourseListViewController()
                self.show(viewController, sender: self)
            }

            return
        }

        if self.courseDownloads.isEmpty { return }

        if self.isEditing {
            self.updateToolBarButtons()
            tableView.cellForRow(at: indexPath)?.selectedBackgroundView = UIView(backgroundColor: ColorCompatibility.secondarySystemGroupedBackground)
            return
        }

        let section = self.hasAdditionalSection ? indexPath.section - 1 : indexPath.section
        let courseId = self.courseDownloads[section].id

        switch self.downloadType(for: indexPath) {
        case .video:
            let viewController = DownloadedContentTypeListViewController(forCourseId: courseId, configuration: DownloadedStreamsListConfiguration.self)
            self.navigationController?.pushViewController(viewController, animated: trueUnlessReduceMotionEnabled)
        case .slides:
            let viewController = DownloadedContentTypeListViewController(forCourseId: courseId, configuration: DownloadedSlidesListConfiguration.self)
            self.navigationController?.pushViewController(viewController, animated: trueUnlessReduceMotionEnabled)
        case .document:
            let viewController = DownloadedContentTypeListViewController(forCourseId: courseId, configuration: DownloadedDocumentsListConfiguration.self)
            self.navigationController?.pushViewController(viewController, animated: trueUnlessReduceMotionEnabled)
        }

    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.hasAdditionalSection, indexPath.section == 0 { return }
        if self.courseDownloads.isEmpty { return }
        guard self.isEditing else { return }
        self.updateToolBarButtons()
        tableView.cellForRow(at: indexPath)?.selectedBackgroundView = nil
    }

}

extension DownloadedContentListViewController { // editing

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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let section = self.hasAdditionalSection ? indexPath.section - 1 : indexPath.section

        let alert = UIAlertController { _ in
            let downloadItem = self.courseDownloads[section]
            let course = self.fetchCourse(withID: downloadItem.id).require(hint: "Course has to exist")
            self.downloadType(for: indexPath).persistenceManager.deleteDownloads(for: course)
        }

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return !(self.hasAdditionalSection && indexPath.section == 0)
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

        self.selectAllBarButton.title = title
        self.deleteBarButton.isEnabled = !(self.tableView.indexPathsForSelectedRows?.isEmpty ?? true)
    }

    private var allIndexPaths: [IndexPath] {
        let startSection = self.hasAdditionalSection ? 1 : 0
        return (startSection..<self.tableView.numberOfSections).flatMap { section in
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
        self.updateToolBarButtons()
    }

    @IBAction private func deleteSelectedIndexPaths() {
        guard let indexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }

        let alert = UIAlertController { [weak self] _ in
            guard let self = self else { return }

            for indexPath in indexPaths {
                let section = self.hasAdditionalSection ? indexPath.section - 1 : indexPath.section
                let downloadItem = self.courseDownloads[section]
                let course = self.fetchCourse(withID: downloadItem.id).require(hint: "Course has to exist")
                self.downloadType(for: indexPath).persistenceManager.deleteDownloads(for: course)
            }

            self.setEditing(false, animated: trueUnlessReduceMotionEnabled)
        }

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

}

extension DownloadedContentListViewController: EmptyStateDataSource {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.account.download.no-downloads.title", comment: "title for empty download list")
    }

    var emptyStateDetailText: String? {
        return NSLocalizedString("empty-view.account.download.no-downloads.description", comment: "description for empty download list")
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
        self.tableView.tableFooterView = UIView()
    }

}
