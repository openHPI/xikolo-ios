//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension Video {

    enum DownloadState: String {

        // The asset is not downloaded at all.
        case notDownloaded

        // The asset is waiting to be downloaded.
        case pending

        // The asset has a download in progress.
        case downloading

        // The asset is downloaded and saved on disk.
        case downloaded
    }

}

extension Video {

    struct Keys {

        static let id = "VideoIdKey"
        static let downloadState = "VideoDownloadStateKey"
        static let precentDownload = "VideoPrecentDownloadKey"

    }

}

extension Video {

    var alertActions: [UIAlertAction] {
        return [self.videoAlertAction].flatMap { $0 }
    }

    private var videoAlertAction: UIAlertAction? {
        let isOffline = ReachabilityHelper.connection == .none
        let downloadState = VideoPersistenceManager.shared.downloadState(for: self)

        if downloadState == .notDownloaded && !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.video-download-alert.start-download-action.title",
                                                        comment: "start download of video item")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                VideoPersistenceManager.shared.downloadStream(for: self)
            }
        }

        if downloadState == .pending || downloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.video-download-alert.stop-download-action.title",
                                                     comment: "stop download of video item")
            return UIAlertAction(title: abortActionTitle, style: .default) { _ in
                VideoPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if downloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.video-download-alert.delete-item-action.title",
                                                      comment: "delete video item")
            return UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                VideoPersistenceManager.shared.deleteAsset(for: self)
            }
        }

        return nil
    }

}
