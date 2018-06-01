//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import UIKit

final class SlidesPersistenceManager: NSObject, FilePersistenceManager {

    static var shared = SlidesPersistenceManager(keyPath: \Video.localSlidesBookmark)

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

    func didFailToDownloadResource(_ resource: Video, with error: NSError) {
        CrashlyticsHelper.shared.setObjectValue((Resource.type, resource.id), forKey: "resource")
        CrashlyticsHelper.shared.recordError(error)
        log.error("Unknown asset download error (resource type: \(Resource.type) | resource id: \(resource.id) | domain: \(error.domain) | code: \(error.code)")

        // show error
        DispatchQueue.main.async {
            let alertTitle = "Slide Download Error"
            let alertMessage = "Domain: \(error.domain)\nCode: \(error.code)"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let actionTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                alert.dismiss(animated: true)
            })

            AppDelegate.instance().tabBarController?.present(alert, animated: true)
        }
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
