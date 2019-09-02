//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

final class SlidesPersistenceManager: NSObject, FilePersistenceManager {

    static let shared = SlidesPersistenceManager(keyPath: \Video.localSlidesBookmark)
    static let downloadType = "slides"
    static let titleForFailedDownloadAlert = NSLocalizedString("alert.download-error.slides.title",
                                                               comment: "title of alert for slides download errors")

    lazy var persistentContainerQueue = self.createPersistenceContainerQueue()
    lazy var session: URLSession = self.createURLSession(withIdentifier: "slides-download")

    var activeDownloads: [URLSessionTask: String] = [:]
    var progresses: [String: Double] = [:]
    var didRestorePersistenceManager: Bool = false

    var keyPath: ReferenceWritableKeyPath<Video, NSData?>

    init(keyPath: ReferenceWritableKeyPath<Video, NSData?>) {
        self.keyPath = keyPath
        super.init()
        self.startListeningToDownloadProgressChanges()
    }

    var fetchRequest: NSFetchRequest<Video> {
        return Video.fetchRequest()
    }

    func startDownload(for video: Video) {
        guard let url = video.slidesURL else { return }
        self.startDownload(with: url, for: video)
    }

    private func trackingContext(for video: Video) -> [String: String?] {
        return [
            "section_id": video.item?.section?.id,
            "course_id": video.item?.section?.course?.id,
            "free_space": String(describing: SlidesPersistenceManager.systemFreeSize),
            "total_space": String(describing: SlidesPersistenceManager.systemSize),
        ]
    }

    func didStartDownload(for resource: Video) {
        TrackingHelper.createEvent(.slidesDownloadStart,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource))
    }

    func didCancelDownload(for resource: Video) {
        TrackingHelper.createEvent(.slidesDownloadCanceled,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource))
    }

    func didFinishDownload(for resource: Video) {
        TrackingHelper.createEvent(.slidesDownloadFinished,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource))
    }

}

extension SlidesPersistenceManager {

    func startDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return SlidesPersistenceManager.shared.downloadState(for: video) == .notDownloaded
            }.forEach { video in
                self.startDownload(for: video)
            }
        }
    }

    func deleteDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.forEach { video in
                self.deleteDownload(for: video)
            }
        }
    }

    func cancelDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return [.pending, .downloading].contains(SlidesPersistenceManager.shared.downloadState(for: video))
            }.forEach { video in
                self.cancelDownload(for: video)
            }
        }
    }

}

extension SlidesPersistenceManager: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.downloadTask(task, didCompleteWithError: error)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.downloadTask(downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        self.downloadTask(downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

}
