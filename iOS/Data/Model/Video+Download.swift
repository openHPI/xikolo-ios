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

    var slidesUserAction: UIAlertAction? {
        let downloadStruct = DownloadSlidesStruct(video: self)
        guard let title = downloadStruct.title, let action = downloadStruct.action else { return nil }
        return UIAlertAction(title: title, style: .default) { _ in
            action
        }
    }

    var streamUserAction: UIAlertAction? {
           let downloadStruct = DownloadStreamStruct(video: self)
           guard let title = downloadStruct.title, let action = downloadStruct.action else { return nil }
           return UIAlertAction(title: title, style: .default) { _ in
               action
           }
       }

    @available(iOS 13.0, *)
    var downloadStreamAction: UIAction? {
        let downloadStruct = DownloadStreamStruct(video: self)
        guard let title = downloadStruct.title, let action = downloadStruct.action else { return nil }
        return UIAction(title: title, image: downloadStruct.icon) { _ in
            action
        }
    }

    @available(iOS 13.0, *)
    var downloadSlidesAction: UIAction? {
        let downloadStruct = DownloadSlidesStruct(video: self)
        guard let title = downloadStruct.title, let action = downloadStruct.action else { return nil }
        return UIAction(title: title, image: downloadStruct.icon) { _ in
            action
        }
    }

    struct DownloadStreamStruct {
        var title: String?
        var icon: UIImage?
        var action: ()?

        init(video: Video) {
            let isOffline = !ReachabilityHelper.hasConnection
            let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: video)

            if let url = video.streamURLForDownload, streamDownloadState == .notDownloaded, !isOffline {
                let downloadActionTitle = NSLocalizedString("course-item.stream-download-action.start-download.title",
                                                            comment: "start download of stream for video")
                self.title = downloadActionTitle
                if #available(iOS 13.0, *) {
                    self.icon = UIImage(systemName: "arrow.down.left.video")
                }

                self.action = StreamPersistenceManager.shared.startDownload(with: url, for: video)
            } else if streamDownloadState == .pending || streamDownloadState == .downloading {
                let abortActionTitle = NSLocalizedString("course-item.stream-download-action.stop-download.title",
                                                         comment: "stop stream download for video")
                self.title = abortActionTitle
                if #available(iOS 13.0, *) {
                    self.icon = UIImage(systemName: "stop.circle")
                }

                self.action = StreamPersistenceManager.shared.cancelDownload(for: video)
            } else if streamDownloadState == .downloaded {
                let deleteActionTitle = NSLocalizedString("course-item.stream-download-action.delete-download.title",
                                                          comment: "delete stream download for video")
                self.title = deleteActionTitle
                if #available(iOS 13.0, *) {
                    self.icon = UIImage(systemName: "trash")
                }

                self.action = StreamPersistenceManager.shared.deleteDownload(for: video)
            }
        }
    }

    struct DownloadSlidesStruct {
        var title: String?
        var icon: UIImage?
        var action: ()?

        init(video: Video) {

            let isOffline = !ReachabilityHelper.hasConnection
            let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: video)

            if let url = video.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.slides-download-action.start-download.title",
                                                        comment: "start download of slides for video")
                self.title = downloadActionTitle
                if #available(iOS 13.0, *) {
                    self.icon = UIImage(systemName: "arrow.down.doc")
                }

                self.action = SlidesPersistenceManager.shared.startDownload(with: url, for: video)
            } else if slidesDownloadState == .pending || slidesDownloadState == .downloading {
                let abortActionTitle = NSLocalizedString("course-item.slides-download-action.stop-download.title",
                                                         comment: "stop slides download for video")
                self.title = abortActionTitle
                if #available(iOS 13.0, *) {
                    self.icon = UIImage(systemName: "stop.circle")
                }

                self.action = SlidesPersistenceManager.shared.cancelDownload(for: video)
            } else if slidesDownloadState == .downloaded {
                let deleteActionTitle = NSLocalizedString("course-item.slides-download-action.delete-download.title",
                                                          comment: "delete slides download for video")
                self.title = deleteActionTitle
                if #available(iOS 13.0, *) {
                    self.icon = UIImage(systemName: "trash")
                }

                self.action = SlidesPersistenceManager.shared.deleteDownload(for: video)
            }
        }
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
