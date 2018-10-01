//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension DocumentLocalization: Persistable {

    static let identifierKeyPath: WritableKeyPath<DocumentLocalization, String> = \DocumentLocalization.id

}

extension DocumentLocalization {

    var userActions: [UIAlertAction] {
        return [self.downloadAction].compactMap { $0 }
    }

    private var downloadAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let downloadState = DocumentsPersistenceManager.shared.downloadState(for: self)

        if let url = self.fileURL, downloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("document-localization.download-action.start-download.title",
                                                        comment: "start download of a document localization")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                DocumentsPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if downloadState == .pending || downloadState == .downloading {
            let abortActionTitle = NSLocalizedString("document-localization.download-action.stop-download.title",
                                                     comment: "stop download of a document localization")
            return UIAlertAction(title: abortActionTitle, style: .default) { _ in
                DocumentsPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if downloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("document-localization.download-action.delete-download.title",
                                                      comment: "delete download of a document localization")
            return UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                DocumentsPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

}
