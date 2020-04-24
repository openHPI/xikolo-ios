//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

enum DocumentPersistenceManagerConfiguration: PersistenceManagerConfiguration {

    typealias Resource = DocumentLocalization
    typealias Session = URLSession

    static let keyPath = \DocumentLocalization.localFileBookmark
    static let downloadType = "documents"
    static let titleForFailedDownloadAlert = NSLocalizedString("alert.download-error.documents.title",
                                                               comment: "title of alert for stream download errors")

    static func newFetchRequest() -> NSFetchRequest<DocumentLocalization> {
        return DocumentLocalization.fetchRequest()
    }

}

final class DocumentsPersistenceManager: FilePersistenceManager<DocumentPersistenceManagerConfiguration> {

    static let shared = DocumentsPersistenceManager()

    override func newDownloadSession() -> URLSession {
        return self.createURLSession(withIdentifier: "documents-download")
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
                return self.downloadState(for: documentLocalization) == .downloaded
            }.forEach { documentLocalization in
                self.deleteDownload(for: documentLocalization)
            }
        }
    }

}
