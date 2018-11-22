//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

final class DocumentsPersistenceManager: NSObject, FilePersistenceManager {

    static var shared = DocumentsPersistenceManager(keyPath: \DocumentLocalization.localFileBookmark)
    static var downloadType = "documents"

    lazy var persistentContainerQueue = self.createPersistenceContainerQueue()
    lazy var session: URLSession = self.createURLSession(withIdentifier: "documents-download")

    var activeDownloads: [URLSessionTask: String] = [:]
    var progresses: [String: Double] = [:]
    var didRestorePersistenceManager: Bool = false

    var keyPath: ReferenceWritableKeyPath<DocumentLocalization, NSData?>

    init(keyPath: ReferenceWritableKeyPath<DocumentLocalization, NSData?>) {
        self.keyPath = keyPath
        super.init()
        self.startListeningToDownloadProgressChanges()
    }

    var fetchRequest: NSFetchRequest<DocumentLocalization> {
        return DocumentLocalization.fetchRequest()
    }

    func startDownload(for documentLocalization: DocumentLocalization) {
        guard let url = documentLocalization.fileURL else { return }
        self.startDownload(with: url, for: documentLocalization)
    }

    func didFailToDownloadResource(_ resource: DocumentLocalization, with error: NSError) {
        ErrorManager.shared.remember((Resource.type, resource.id), forKey: "resource")
        ErrorManager.shared.report(error)
        log.error("Unknown asset download error (resource type: \(Resource.type) | resource id: \(resource.id) | domain: \(error.domain) | code: \(error.code)")

        // show error
        DispatchQueue.main.async {
            let alertTitle = "Document Download Error"
            let alertMessage = "Domain: \(error.domain)\nCode: \(error.code)"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let actionTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                alert.dismiss(animated: trueUnlessReduceMotionEnabled)
            })

            AppDelegate.instance().tabBarController?.present(alert, animated: trueUnlessReduceMotionEnabled)
        }
    }

}

extension DocumentsPersistenceManager {

    func deleteDownloads(for course: Course) {
        self.persistentContainerQueue.addOperation {
            course.documents.forEach { document in
                document.localizations.filter { documentLocalization -> Bool in
                    return DocumentsPersistenceManager.shared.downloadState(for: documentLocalization) == .downloaded
                }.forEach { documentLocalization in
                    self.deleteDownload(for: documentLocalization)
                }
            }
        }
    }

}

extension DocumentsPersistenceManager: URLSessionDownloadDelegate {

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
