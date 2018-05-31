//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension Video {

    var userActions: [UIAlertAction] {
        return [self.videoUserAction].compactMap { $0 }
    }

    var videoUserAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let downloadState = StreamPersistenceManager.shared.downloadState(for: self)

        if downloadState == .notDownloaded && !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.video-download-action.start-download.title",
                                                        comment: "start download of video item")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.startDownload(for: self)
            }
        }

        if downloadState == .pending || downloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.video-download-action.stop-download.title",
                                                     comment: "stop download of video item")
            return UIAlertAction(title: abortActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if downloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.video-download-action.delete-item.title",
                                                      comment: "delete video item")
            return UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

}
