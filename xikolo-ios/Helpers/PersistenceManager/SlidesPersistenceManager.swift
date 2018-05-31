//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

final class SlidesPersistenceManager: NSObject, FilePersistenceManager {

    //    typealias Resource = Video

    static var shared = SlidesPersistenceManager(keyPath: \Video.localFileBookmark) /// XXX: Change keypath

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

    func didFailToDownloadResource(_ resource: Video, with error: NSError) {
//        XXX
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
