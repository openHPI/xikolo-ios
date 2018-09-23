//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import Foundation
import UIKit

class DownloadListViewController: UITableViewController {

    var dataSource: CoreDataTableViewDataSource<DownloadListViewController>!
    var hasDocuments: Bool = false
    var courses: [CourseDownload] = []
    var courseTitles: [(courseTitle: String, courseID: String)] = []
    var downloadItems: [DownloadItem] = []



    override func viewDidLoad() {
        super.viewDidLoad()

        self.getData().onSuccess { (itemsArray) in
            self.downloadItems = itemsArray.flatMap {$0}
            var downloadedCourseList: [String:CourseDownload] = [:]
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




//            for downloadItem in self.downloadItems {
//                if var content = courses[downloadItem.courseID]?.content {
//                    content.update(with: downloadItem.contentType) // TODO: Test
//                } else {
//                    courses[downloadItem.courseID] = CourseItem(courseID: downloadItem.courseID,
//                                                                courseTitle: downloadItem.courseTitle,
//                                                                content: courses[downloadItem.courseID]?.content)
//                }
//                courses[downloadItem.courseID] = CourseItem(courseID: downloadItem.courseID,
//                                                            courseTitle: downloadItem.courseTitle,
//                                                            content: Set(downloadItem.contentType)
//                courses[downloadItem.courseID]?.update(with: downloadItem.contentType)
//                courseTitles[downloadItem.courseTitle ?? ""]
//            }
        }
        // setup table view data
//        let reuseIdentifier = R.reuseIdentifier.downloadedCourse.identifier
//        self.getData().onSuccess { (downloadItems) in
//
//        }

    }

    func getData() -> Future<[[DownloadItem]], XikoloError> {
        var futures = [getVideoCourseIDs(), getSlidesCourseIDs()]
//        if Brand.default.features.enableDocuments {
//            futures.append(getDocumentsCourseIDs())
//        }
        return futures.sequence()
    }

    func getVideoCourseIDs() -> Future<[DownloadItem], XikoloError> {
        let videoRequest = VideoHelper.FetchRequest.hasDownloadedVideo()
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { (privateManagedObjectContext) in
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
        CoreDataHelper.persistentContainer.performBackgroundTask { (privateManagedObjectContext) in
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
        let documentsRequest = DocumentHelper.FetchRequest.downloaded()
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { (privateManagedObjectContext) in
            do {
                let downloadedDocuments = try privateManagedObjectContext.fetch(documentsRequest)
                if !downloadedDocuments.isEmpty {
                    self.hasDocuments = true
                }
                for document in downloadedDocuments {
                    let downloadItems = document.courses.map({ (course) -> DownloadItem in
                        return DownloadItem(courseID: course.id, courseTitle: course.title, contentType: .document)})
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
        // #warning Incomplete implementation, return the number of sections
        return courses.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courses[section].properties.filter( { $0 } ).count
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
                    return DownloadItem.DownloadType(rawValue: returnCount) ?? .video
                }
                itemCount += 1
            }
            returnCount += 1
        }
        return .video
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courses[section].title
    }

    func getTitle(for downloadType: DownloadItem.DownloadType?) -> String? {
        guard let downloadType = downloadType else { return nil }
        switch downloadType {
        case .video:
            return NSLocalizedString("settings.downloads.item.video", comment: "")
        case .slides:
            return NSLocalizedString("settings.downloads.item.stream", comment: "")
        case .document:
            return NSLocalizedString("settings.downloads.item.document", comment: "")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "" {
//            let vc = segue.destination.require(toHaveType: DownloadItemListViewController.self)
//            vc.downloadType =
//        }
//    }

}

extension DownloadListViewController: CoreDataTableViewDataSourceDelegate {
    typealias Object = Course
    typealias Cell = DownloadedCourseCell

    func configure(_ cell: Cell, for object: Object) {
        cell.configure(for: object)
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

fileprivate struct CourseItem {
    var courseID: String
    var courseTitle: String
    var content: Set<DownloadItem.DownloadType>
}
