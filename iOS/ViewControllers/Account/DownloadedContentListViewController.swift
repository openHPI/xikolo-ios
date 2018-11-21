//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import DZNEmptyDataSet
import Foundation
import UIKit

class DownloadedContentListViewController: UITableViewController {

    struct CourseDownload {
        var id: String
        var title: String
        var properties: [Bool] = [false, false, false]

        init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    private struct DownloadItem {
        var courseID: String
        var courseTitle: String?
        var contentType: DownloadType
    }

    private enum DownloadType: Int {
        case video = 0
        case slides = 1
        case document = 2
    }

    private var courses: [CourseDownload] = []
    private var courseTitles: [(courseTitle: String, courseID: String)] = []
    private var downloadItems: [DownloadItem] = []

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupEmptyState()
        self.refresh()
    }

    func refreshAndDismissIfEmpty() {
        self.refresh().onSuccess { _ in
            if self.courses.isEmpty {
                self.navigationController?.popToRootViewController(animated: trueUnlessReduceMotionEnabled)
            }
        }
    }

    @discardableResult
    private func refresh() -> Future<[[DownloadItem]], XikoloError> {
        return self.courseIDs().onSuccess { itemsArray in
            self.downloadItems = itemsArray.flatMap { $0 }
            var downloadedCourseList: [String: CourseDownload] = [:]
            for downloadItem in self.downloadItems {
                let courseId = downloadItem.courseID
                var courseDownload = downloadedCourseList[courseId, default: CourseDownload(id: courseId, title: downloadItem.courseTitle ?? "")]
                courseDownload.properties[downloadItem.contentType.rawValue] = true
                downloadedCourseList[downloadItem.courseID] = courseDownload
            }

            self.courses = downloadedCourseList.values.sorted { $0.title < $1.title }
            self.navigationItem.rightBarButtonItem = self.courses.isEmpty ? nil : self.editButtonItem
            self.tableView.reloadData()
        }.onFailure { error in
            log.error(error.localizedDescription)
        }
    }

    private func courseIDs() -> Future<[[DownloadItem]], XikoloError> {
        var futures = [streamCourseIDs(), slidesCourseIDs()]

        if Brand.default.features.enableDocuments {
            futures.append(documentsCourseIDs())
        }

        return futures.sequence()
    }

    private func streamCourseIDs() -> Future<[DownloadItem], XikoloError> {
        return self.courseIDs(fetchRequest: VideoHelper.FetchRequest.hasDownloadedVideo(),
                              contentType: .video,
                              keyPath: \Video.item?.section?.course)
    }

    private func slidesCourseIDs() -> Future<[DownloadItem], XikoloError> {
        return self.courseIDs(fetchRequest: VideoHelper.FetchRequest.hasDownloadedSlides(),
                              contentType: .slides,
                              keyPath: \Video.item?.section?.course)
    }

    private func documentsCourseIDs() -> Future<[DownloadItem], XikoloError> {
        return self.courseIDs(fetchRequest: DocumentHelper.FetchRequest.hasDownloadedLocalization(),
                              contentType: .document,
                              keyPath: \Document.courses)
    }

    private func courseIDs<Resource>(fetchRequest: NSFetchRequest<Resource>,
                                     contentType: DownloadType,
                                     keyPath: KeyPath<Resource, Course?>) -> Future<[DownloadItem], XikoloError> {

        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedItems = try privateManagedObjectContext.fetch(fetchRequest)
                for video in downloadedItems {
                    if let course = video[keyPath: keyPath] {
                        items.append(DownloadItem(courseID: course.id, courseTitle: course.title, contentType: contentType))
                    }
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    private func courseIDs<Resource>(fetchRequest: NSFetchRequest<Resource>,
                                     contentType: DownloadType,
                                     keyPath: KeyPath<Resource, Set<Course>>) -> Future<[DownloadItem], XikoloError> {
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedItems = try privateManagedObjectContext.fetch(fetchRequest)
                for item in downloadedItems {
                    let downloadItems = item[keyPath: keyPath].map { course -> DownloadItem in
                        return DownloadItem(courseID: course.id, courseTitle: course.title, contentType: contentType)
                    }

                    items.append(contentsOf: downloadItems)
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.courses.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses[section].properties.filter { $0 }.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.downloadTypeCell, for: indexPath).require()
        cell.textLabel?.text = self.title(for: downloadType(for: indexPath))
        return cell
    }

    private func downloadType(for indexPath: IndexPath) -> DownloadType {
        var itemCount = 0
        var returnCount = 0
        for itemExists in self.courses[indexPath.section].properties {
            if itemExists {
                if indexPath.row == itemCount {
                    return DownloadType(rawValue: returnCount).require(hint: "Trying to initialize DownloadType from invalid value")
                }

                itemCount += 1
            }

            returnCount += 1
        }

        preconditionFailure("Invalid data in download list view")
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.courses[section].title
    }

    private func title(for downloadType: DownloadType?) -> String? {
        guard let downloadType = downloadType else { return nil }
        switch downloadType {
        case .video:
            return NSLocalizedString("settings.downloads.item.video", comment: "download type video")
        case .slides:
            return NSLocalizedString("settings.downloads.item.slides", comment: "download type slides")
        case .document:
            return NSLocalizedString("settings.downloads.item.document", comment: "download type documents")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch downloadType(for: indexPath) {
        case .video:
            performSegue(withIdentifier: R.segue.downloadedContentListViewController.showVideoDownloads, sender: self.courses[indexPath.section])
        case .slides:
            performSegue(withIdentifier: R.segue.downloadedContentListViewController.showSlideDownloads, sender: self.courses[indexPath.section])
        case .document:
            performSegue(withIdentifier: R.segue.downloadedContentListViewController.showDocumentDownloads, sender: self.courses[indexPath.section])
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let course = self.fetchCourse(withID: self.courses[indexPath.section].id).require(hint: "Course has to exist")
        if editingStyle == .delete {
            let courseTitle = self.courses[indexPath.section].title
            switch self.downloadType(for: indexPath) {
            case .video:
                let title = NSLocalizedString("settings.downloads.alert.delete.title.streams", comment: "title for deleting streams")
                let format = NSLocalizedString("settings.downloads.alert.delete.message.streams for course %@", comment: "message for deleting streams")
                let message = String.localizedStringWithFormat(format, courseTitle)
                self.showAlertForDeletingContent(withTitle: title, message: message) { _ in
                    StreamPersistenceManager.shared.deleteDownloads(for: course)
                }
            case .slides:
                let title = NSLocalizedString("settings.downloads.alert.delete.title.slides", comment: "title for deleting slides")
                let format = NSLocalizedString("settings.downloads.alert.delete.message.slides for course %@", comment: "message for deleting slides")
                let message = String.localizedStringWithFormat(format, courseTitle)
                self.showAlertForDeletingContent(withTitle: title, message: message) { _ in
                    SlidesPersistenceManager.shared.deleteDownloads(for: course)
                }
            case .document:
                let title = NSLocalizedString("settings.downloads.alert.delete.title.documents", comment: "title for deleting documents")
                let format = NSLocalizedString("settings.downloads.alert.delete.message.documents for course %@", comment: "message for deleting documents")
                let message = String.localizedStringWithFormat(format, courseTitle)
                self.showAlertForDeletingContent(withTitle: title, message: message) { _ in
                    DocumentsPersistenceManager.shared.deleteDownloads(for: course)
                }
            }
        }
    }

    func showAlertForDeletingContent(withTitle title: String, message: String, action: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteTitle = NSLocalizedString("global.alert.delete", comment: "title to delete alert")
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive, handler: action)
        alert.addAction(deleteAction)
        alert.addCancelAction()
        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    func fetchCourse(withID id: String) -> Course? {
        let request = CourseHelper.FetchRequest.course(withSlugOrId: id)
        return CoreDataHelper.viewContext.fetchSingle(request).value
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let downloadItem = (sender as? CourseDownload).require(hint: "Sender must be DownloadItem")

        if let typedInfo = R.segue.downloadedContentListViewController.showVideoDownloads(segue: segue) {
            typedInfo.destination.configure(for: downloadItem)
        } else if let typedInfo = R.segue.downloadedContentListViewController.showSlideDownloads(segue: segue) {
            typedInfo.destination.configure(for: downloadItem)
        } else if let typedInfo = R.segue.downloadedContentListViewController.showDocumentDownloads(segue: segue) {
            typedInfo.destination.configure(for: downloadItem)
        }
    }

    @objc private func coreDataChange(notification: Notification) {
        let keys = [NSDeletedObjectsKey, NSRefreshedObjectsKey, NSUpdatedObjectsKey]
        let containsVideoDeletion = notification.includesChanges(for: Video.self, keys: keys)
        let containsDocumentDeletion = notification.includesChanges(for: DocumentLocalization.self, keys: keys)
        if containsVideoDeletion || containsDocumentDeletion {
            self.refreshAndDismissIfEmpty()
        }
    }

}

extension DownloadedContentListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.account.download.no-downloads.title", comment: "title for empty download list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.account.download.no-downloads.description", comment: "description for empty download list")
        return NSAttributedString(string: description)
    }

}
