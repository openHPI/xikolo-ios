//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension Video: Persistable {

    static let identifierKeyPath: WritableKeyPath<Video, String> = \Video.id

    override public func prepareForDeletion() { // swiftlint:disable:this override_in_extension
        super.prepareForDeletion()
        StreamPersistenceManager.shared.prepareForDeletion(of: self)
        SlidesPersistenceManager.shared.prepareForDeletion(of: self)
    }

}

extension Video {

    var streamURLForDownload: URL? {
        return self.singleStream?.hlsURL
    }

    var userActions: [UIAlertAction] {
        return [self.streamUserAction, self.slidesUserAction].compactMap { $0 } + self.combinedUserActions
    }

    var streamUserAction: UIAlertAction? {
        let isOffline = !ReachabilityHelper.hasConnection
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)

        if let url = self.streamURLForDownload, streamDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.stream-download-action.start-download.title",
                                                        comment: "start download of stream for video")
            return UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.startDownload(with: url, for: self)
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
        let isOffline = !ReachabilityHelper.hasConnection
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

    var combinedUserActions: [UIAlertAction] {
        var actions: [UIAlertAction] = []

        let isOffline = !ReachabilityHelper.hasConnection
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let streamURL = self.streamURLForDownload, streamDownloadState == .notDownloaded,
            let slidesURL = self.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.combined-download-action.start-download.title",
                                                        comment: "start all downloads for video")
            actions.append(UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.startDownload(with: streamURL, for: self)
                SlidesPersistenceManager.shared.startDownload(with: slidesURL, for: self)
            })
        }

        if streamDownloadState == .pending || streamDownloadState == .downloading, slidesDownloadState == .pending || slidesDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.combined-download-action.stop-download.title",
                                                     comment: "stop all downloads for video")
            actions.append(UIAlertAction(title: abortActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.cancelDownload(for: self)
                SlidesPersistenceManager.shared.cancelDownload(for: self)
            })
        }

        if streamDownloadState == .downloaded, slidesDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.combined-download-action.delete-download.title",
                                                      comment: "delete all downloads for video")
            actions.append(UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.deleteDownload(for: self)
                SlidesPersistenceManager.shared.deleteDownload(for: self)
            })
        }

        return actions
    }

}
