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
        return [self.streamUserAction, self.slidesUserAction].compactMap { $0 } + [self.combinedUserActions]
    }

    @available(iOS 13.0, *)
    var actions: [UIAction]? {
        var actions = [self.downloadStreamAction, self.downloadSlidesAction].compactMap { $0 }
        if let combinedAction = self.combinedAction {
            actions.append(combinedAction)
        }

        return actions
    }

    struct StreamAction {
        var title: String
        var image: UIImage?
        var action: ()?

        init(video: Video) {
            self.title = ""
            self.image = nil
            self.action = nil

            let isOffline = !ReachabilityHelper.hasConnection
            let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: video)

            if let url = video.streamURLForDownload, streamDownloadState == .notDownloaded, !isOffline {
                let downloadActionTitle = NSLocalizedString("course-item.stream-download-action.start-download.title",
                                                            comment: "start download of stream for video")
                self.title = downloadActionTitle
                if #available(iOS 13.0, *) {
                    self.image = UIImage(systemName: "arrow.down.left.video")
                }

                self.action = StreamPersistenceManager.shared.startDownload(with: url, for: video)
            } else if streamDownloadState == .pending || streamDownloadState == .downloading {
                let abortActionTitle = NSLocalizedString("course-item.stream-download-action.stop-download.title",
                                                         comment: "stop stream download for video")
                self.title = abortActionTitle
                if #available(iOS 13.0, *) {
                    self.image = UIImage(systemName: "stop.circle")
                }

                self.action = StreamPersistenceManager.shared.cancelDownload(for: video)
            } else if streamDownloadState == .downloaded {
                let deleteActionTitle = NSLocalizedString("course-item.stream-download-action.delete-download.title",
                                                          comment: "delete stream download for video")
                self.title = deleteActionTitle
                if #available(iOS 13.0, *) {
                    self.image = UIImage(systemName: "trash")
                }

                self.action = StreamPersistenceManager.shared.deleteDownload(for: video)
            }
        }
    }

    struct SlidesAction {
         var title: String
         var image: UIImage?
         var action: ()?

         init(video: Video) {
             self.title = ""
             self.image = nil
             self.action = nil

             let isOffline = !ReachabilityHelper.hasConnection
             let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: video)

             if let url = video.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
                 let downloadActionTitle = NSLocalizedString("course-item.slides-download-action.start-download.title",
                                                             comment: "start download of slides for video")
                 self.title = downloadActionTitle
                 if #available(iOS 13.0, *) {
                     self.image = UIImage(systemName: "arrow.down.doc")
                 }

                 self.action = SlidesPersistenceManager.shared.startDownload(with: url, for: video)
             } else if  slidesDownloadState == .pending || slidesDownloadState == .downloading {
                 let abortActionTitle = NSLocalizedString("course-item.slides-download-action.stop-download.title",
                                                          comment: "stop slides download for video")
                 self.title = abortActionTitle
                 if #available(iOS 13.0, *) {
                     self.image = UIImage(systemName: "stop.circle")
                }

                 self.action = SlidesPersistenceManager.shared.cancelDownload(for: video)
             } else if slidesDownloadState == .downloaded {
                 let deleteActionTitle = NSLocalizedString("course-item.slides-download-action.delete-download.title",
                                                           comment: "delete slides download for video")
                 self.title = deleteActionTitle
                 if #available(iOS 13.0, *) {
                     self.image = UIImage(systemName: "trash")
                 }

                 self.action = SlidesPersistenceManager.shared.deleteDownload(for: video)
             }
         }
     }

    struct CombinedActions {
        var title: String
        var image: UIImage?
        var actions = [()]

        init(video: Video) {
            self.title = ""

            let isOffline = !ReachabilityHelper.hasConnection
            let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: video)
            let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: video)

            if let streamURL = video.streamURLForDownload, streamDownloadState == .notDownloaded,
                let slidesURL = video.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
                let downloadActionTitle = NSLocalizedString("course-item.combined-download-action.start-download.title",
                                                            comment: "start all downloads for video")
                self.title = downloadActionTitle
                if #available(iOS 13.0, *) {
                    self.image = UIImage(systemName: "square.and.arrow.down")
                }

                self.actions.append(StreamPersistenceManager.shared.startDownload(with: streamURL, for: video))
                self.actions.append(SlidesPersistenceManager.shared.startDownload(with: slidesURL, for: video))
            } else if streamDownloadState == .pending || streamDownloadState == .downloading,
                slidesDownloadState == .pending || slidesDownloadState == .downloading {
                let abortActionTitle = NSLocalizedString("course-item.combined-download-action.stop-download.title",
                                                         comment: "stop all downloads for video")
                self.title = abortActionTitle
                if #available(iOS 13.0, *) {
                    self.image = UIImage(systemName: "stop.circle")
                }

                self.actions.append(StreamPersistenceManager.shared.cancelDownload(for: video))
                self.actions.append(SlidesPersistenceManager.shared.cancelDownload(for: video))
            } else if streamDownloadState == .downloaded, slidesDownloadState == .downloaded {
                let deleteActionTitle = NSLocalizedString("course-item.combined-download-action.delete-download.title",
                                                          comment: "delete all downloads for video")
                self.title = deleteActionTitle
                if #available(iOS 13.0, *) {
                    self.image = UIImage(systemName: "trash")
                }

                self.actions.append(StreamPersistenceManager.shared.deleteDownload(for: video))
                self.actions.append(SlidesPersistenceManager.shared.deleteDownload(for: video))
            }
        }
    }

    @available(iOS 13, *)
    var downloadStreamAction: UIAction? {
        let streamActionStruct = StreamAction(video: self)
        guard let image = streamActionStruct.image, let action = streamActionStruct.action else { return nil }
        if !streamActionStruct.title.isEmpty {
            return UIAction(title: streamActionStruct.title, image: image) { _ in
                action
            }
        } else { return nil }
    }

    @available(iOS 13, *)
    var downloadSlidesAction: UIAction? {
        let slidesActionStruct = SlidesAction(video: self)
        guard let image = slidesActionStruct.image, let action = slidesActionStruct.action else { return nil }
        if !slidesActionStruct.title.isEmpty {
            return UIAction(title: slidesActionStruct.title, image: image) { _ in
                action
            }
        } else { return nil }
    }

    @available(iOS 13, *)
    var combinedAction: UIAction? {
        let combinedActionStruct = CombinedActions(video: self)
        guard let image = combinedActionStruct.image else { return nil }
        if !combinedActionStruct.title.isEmpty {
            return UIAction(title: combinedActionStruct.title, image: image) { _ in
                    for action in combinedActionStruct.actions {
                        action
                    }
            }
        } else { return nil }
    }

    var streamUserAction: UIAlertAction? {
        let streamActionStruct = StreamAction(video: self)
        guard let action = streamActionStruct.action else { return nil }
        if !streamActionStruct.title.isEmpty {
            return UIAlertAction(title: streamActionStruct.title, style: .default) { _ in
                action
            }
        } else { return nil }
    }

    var slidesUserAction: UIAlertAction? {
        let slidesActionStruct = SlidesAction(video: self)
        guard let action = slidesActionStruct.action else { return nil }
        if !slidesActionStruct.title.isEmpty {
               return UIAlertAction(title: slidesActionStruct.title, style: .default) { _ in
                   action
               }
           } else { return nil }
       }

    var combinedUserActions: UIAlertAction {
        let combinedActionStruct = CombinedActions(video: self)
        return UIAlertAction(title: combinedActionStruct.title, style: .default) { _ in
            for action in combinedActionStruct.actions {
                action
            }
        }
    }
}
