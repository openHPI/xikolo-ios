//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension Video {

    var userActions: [UIAlertAction] {
        return [self.videoUserAction, self.slidesUserAction].compactMap { $0 }
    }

    var videoUserAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let downloadState = StreamPersistenceManager.shared.downloadState(for: self)

        if let url = self.singleStream?.hlsURL, downloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.video-download-action.start-download.title",
                                                        comment: "start download of video item")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.startDownload(with:url, for: self)
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

    var slidesUserAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let downloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let url = self.slidesURL, downloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = "download slides"
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                SlidesPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if downloadState == .pending || downloadState == .downloading {
            let abortActionTitle = "stop slide download"
            return UIAlertAction(title: abortActionTitle, style: .default) { _ in
                SlidesPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if downloadState == .downloaded {
            let deleteActionTitle = "delete slides"
            return UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                SlidesPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

}
