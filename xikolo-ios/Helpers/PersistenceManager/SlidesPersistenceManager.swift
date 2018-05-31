//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import UIKit

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

extension SlidesPersistenceManager: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.downloadTask(task, didCompleteWithError: error)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let documentsLocation = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).last else { return }
        do {
            try FileManager.default.moveItem(at: location, to: documentsLocation)
            self.downloadTask(downloadTask, didFinishDownloadingTo: documentsLocation)
        } catch {
            print(error) // XXX: check this again
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        self.downloadTask(downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

}
