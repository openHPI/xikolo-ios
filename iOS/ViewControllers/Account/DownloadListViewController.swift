//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import Foundation
import UIKit

class DownloadListViewController: UITableViewController {

    var hasDocuments: Bool = false
    var courses: [CourseDownload] = []
    var courseTitles: [(courseTitle: String, courseID: String)] = []
    var downloadItems: [DownloadItem] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    func refresh() -> Future<[[DownloadItem]], XikoloError> {
        return self.getData().onSuccess { itemsArray in
            self.downloadItems = itemsArray.flatMap { $0 }
            var downloadedCourseList: [String: CourseDownload] = [:]
            for downloadItem in self.downloadItems {
                if var courseDownload = downloadedCourseList[downloadItem.courseID] {
                    courseDownload.properties[downloadItem.contentType.rawValue] = true
                    downloadedCourseList[downloadItem.courseID] = courseDownload
                } else {
                    var courseDownload = CourseDownload(id: downloadItem.courseID, title: downloadItem.courseTitle ?? "")
                    courseDownload.properties[downloadItem.contentType.rawValue] = true
                    downloadedCourseList[downloadItem.courseID] = courseDownload
                }
            }

            self.courses = downloadedCourseList.values.sorted { $0.title < $1.title }
            self.tableView.reloadData()
        }.onFailure { error in
            log.error(error.localizedDescription)
        }
    }

    func getData() -> Future<[[DownloadItem]], XikoloError> {
        var futures = [getVideoCourseIDs(), getSlidesCourseIDs()]

        if Brand.default.features.enableDocuments {
            futures.append(getDocumentsCourseIDs())
        }

        return futures.sequence()
    }

    func getVideoCourseIDs() -> Future<[DownloadItem], XikoloError> {
        let videoRequest = VideoHelper.FetchRequest.hasDownloadedVideo()
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedVideos = try privateManagedObjectContext.fetch(videoRequest)
                for video in downloadedVideos {
                    if let course = video.item?.section?.course {
                        items.append(DownloadItem(courseID: course.id, courseTitle: course.title, contentType: .video))
                    }
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    func getSlidesCourseIDs() -> Future<[DownloadItem], XikoloError> {
        let slidesRequest = VideoHelper.FetchRequest.hasDownloadedSlides()
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedSlides = try privateManagedObjectContext.fetch(slidesRequest)
                for slide in downloadedSlides {
                    if let course = slide.item?.section?.course {
                        items.append(DownloadItem(courseID: course.id, courseTitle: course.title, contentType: .slides))
                    }
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    func getDocumentsCourseIDs() -> Future<[DownloadItem], XikoloError> {
        let documentsRequest = DocumentHelper.FetchRequest.hasDownloadedLocalization()
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedDocuments = try privateManagedObjectContext.fetch(documentsRequest)
                if !downloadedDocuments.isEmpty {
                    self.hasDocuments = true
                }

                for document in downloadedDocuments {
                    let downloadItems = document.courses.map { course -> DownloadItem in
                        return DownloadItem(courseID: course.id, courseTitle: course.title, contentType: .document)
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
        return courses.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses[section].properties.filter { $0 }.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "streamSlidesCell", for: indexPath)
        cell.textLabel?.text = getTitle(for: downloadType(for: indexPath))
        return cell
    }

    func downloadType(for indexPath: IndexPath) -> DownloadItem.DownloadType {
        var itemCount = 0
        var returnCount = 0
        for itemExists in courses[indexPath.section].properties {
            if itemExists {
                if indexPath.row == itemCount {
                    return DownloadItem.DownloadType(rawValue: returnCount).require(hint: "Trying to initialize DownloadType from invalid value")
                }

                itemCount += 1
            }

            returnCount += 1
        }

        preconditionFailure("Invalid data in download list view")
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courses[section].title
    }

    func getTitle(for downloadType: DownloadItem.DownloadType?) -> String? {
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
            performSegue(withIdentifier: R.segue.downloadListViewController.showVideoDownloads, sender: courses[indexPath.section].id)
        case .slides:
            performSegue(withIdentifier: R.segue.downloadListViewController.showSlideDownloads, sender: courses[indexPath.section].id)
        case .document:
            performSegue(withIdentifier: R.segue.downloadListViewController.showDocumentDownloads, sender: courses[indexPath.section].id)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let course = fetchCourse(withID: courses[indexPath.section].id).require(hint: "Course has to exist")
        if editingStyle == .delete {
            switch downloadType(for: indexPath) {
            case .video:
                StreamPersistenceManager.shared.deleteDownloads(for: course)
            case .slides:
                SlidesPersistenceManager.shared.deleteDownloads(for: course)
            case .document:
                DocumentsPersistenceManager.shared.deleteDownloads(for: course)
            }
        }
    }

    func fetchCourse(withID id: String) -> Course? {
        let request = CourseHelper.FetchRequest.course(withSlugOrId: id)
        return CoreDataHelper.viewContext.fetchSingle(request).value
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let courseID = (sender as? String).require(hint: "Sender must be Course ID")
        switch segue.identifier {
        case "ShowVideoDownloads"?:
            if let typedInfo = R.segue.downloadListViewController.showVideoDownloads(segue: segue) {
                typedInfo.destination.configure(for: courseID)
            }
        case "ShowSlideDownloads"?:
            if let typedInfo = R.segue.downloadListViewController.showSlideDownloads(segue: segue) {
                typedInfo.destination.configure(for: courseID)
            }
        case "ShowDocumentDownloads"?:
            if let typedInfo = R.segue.downloadListViewController.showDocumentDownloads(segue: segue) {
                typedInfo.destination.configure(for: courseID)
            }
        default:
            break
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

struct CourseDownload {
    var id: String
    var title: String
    var properties: [Bool] = [false, false, false]

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

struct DownloadItem {
    var courseID: String
    var courseTitle: String?
    var contentType: DownloadType

    enum DownloadType: Int {
        case video = 0
        case slides = 1
        case document = 2
    }
}

private struct CourseItem {
    var courseID: String
    var courseTitle: String
    var content: Set<DownloadItem.DownloadType>
}
