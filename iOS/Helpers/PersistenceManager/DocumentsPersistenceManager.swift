//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

final class DocumentsPersistenceManager: NSObject, FilePersistenceManager {

    static let shared = DocumentsPersistenceManager(keyPath: \DocumentLocalization.localFileBookmark)
    static let downloadType = "documents"
    static let titleForFailedDownloadAlert = NSLocalizedString("alert.download-error.documents.title",
                                                               comment: "title of alert for stream download errors")

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

}

extension DocumentsPersistenceManager {

    func deleteDownloads(for document: Document) {
        self.persistentContainerQueue.addOperation {
            document.localizations.filter { documentLocalization -> Bool in
                return DocumentsPersistenceManager.shared.downloadState(for: documentLocalization) == .downloaded
            }.forEach { documentLocalization in
                self.deleteDownload(for: documentLocalization)
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
