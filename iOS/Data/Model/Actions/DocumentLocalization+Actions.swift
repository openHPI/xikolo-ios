//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension DocumentLocalization {

    var actions: [Action] {
        return [self.downloadAction].compactMap { $0 }
    }

    private var downloadAction: Action? {
        let isOffline = !ReachabilityHelper.hasConnection
        let downloadState = DocumentsPersistenceManager.shared.downloadState(for: self)

        if let url = self.fileURL, downloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("document-localization.download-action.start-download.title",
                                                        comment: "start download of a document localization")
            return Action(title: downloadActionTitle) {
                DocumentsPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if downloadState == .pending || downloadState == .downloading {
            let abortActionTitle = NSLocalizedString("document-localization.download-action.stop-download.title",
                                                     comment: "stop download of a document localization")
            return Action(title: abortActionTitle) {
                DocumentsPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if downloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("document-localization.download-action.delete-download.title",
                                                      comment: "delete download of a document localization")
            return Action(title: deleteActionTitle) {
                DocumentsPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

}
