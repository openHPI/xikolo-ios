//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension Video {

    var userActions: [UIAlertAction] {
        return [self.streamUserAction, self.slidesUserAction].compactMap { $0 }
    }

    var streamUserAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)

        if let url = self.singleStream?.hlsURL, streamDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.stream-download-action.start-download.title",
                                                        comment: "start download of stream for video")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.startDownload(with:url, for: self)
            }
        }

        if streamDownloadState == .pending || streamDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.stream-download-action.stop-download.title",
                                                     comment: "stop stream download for video")
            return UIAlertAction(title: abortActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if streamDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.stream-download-action.delete-download.title",
                                                      comment: "delete stream download for video")
            return UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

    var slidesUserAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let url = self.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.slides-download-action.start-download.title",
                                                        comment: "start download of slides for video")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                SlidesPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if slidesDownloadState == .pending || slidesDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.slides-download-action.stop-download.title",
                                                     comment: "stop slides download for video")
            return UIAlertAction(title: abortActionTitle, style: .default) { _ in
                SlidesPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if slidesDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.slides-download-action.delete-download.title",
                                                      comment: "delete slides download for video")
            return UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                SlidesPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

}
