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

    var alertActions: [UIAlertAction] {
        return self.availableActions.map(UIAlertAction.init(action:))
    }

    @available(iOS 13.0, *)
    var actions: [UIAction] {
        return self.availableActions.map(UIAction.init(action:))
    }

    var streamAlertAction: UIAlertAction? {
        self.streamUserAction.map(UIAlertAction.init(action:))
    }

    var slidesAlertAction: UIAlertAction? {
        return self.slidesUserAction.map(UIAlertAction.init(action:))
    }

    private var availableActions: [Action] {
        return [self.streamUserAction, self.slidesUserAction].compactMap { $0 } + self.combinedActions
    }

    private var streamUserAction: Action? {
        let isOffline = !ReachabilityHelper.hasConnection
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)

        if let url = self.streamURLForDownload, streamDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.stream-download-action.start-download.title",
                                                        comment: "start download of stream for video")
            return Action(title: downloadActionTitle, image: Action.Image.download) {
                StreamPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if streamDownloadState == .pending || streamDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.stream-download-action.stop-download.title",
                                                     comment: "stop stream download for video")
            return Action(title: abortActionTitle, image: Action.Image.stop) {
                StreamPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if streamDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.stream-download-action.delete-download.title",
                                                      comment: "delete stream download for video")
            return Action(title: deleteActionTitle, image: Action.Image.delete) {
                StreamPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

    private var slidesUserAction: Action? {
        let isOffline = !ReachabilityHelper.hasConnection
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let url = self.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.slides-download-action.start-download.title",
                                                        comment: "start download of slides for video")
            return Action(title: downloadActionTitle, image: Action.Image.download) {
                SlidesPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if slidesDownloadState == .pending || slidesDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.slides-download-action.stop-download.title",
                                                     comment: "stop slides download for video")
            return Action(title: abortActionTitle, image: Action.Image.stop) {
                SlidesPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if slidesDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.slides-download-action.delete-download.title",
                                                      comment: "delete slides download for video")
            return Action(title: deleteActionTitle, image: Action.Image.delete) {
                SlidesPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

    private var combinedActions: [Action] {
        var actions: [Action] = []

        let isOffline = !ReachabilityHelper.hasConnection
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let streamURL = self.streamURLForDownload, streamDownloadState == .notDownloaded,
            let slidesURL = self.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.combined-download-action.start-download.title",
                                                        comment: "start all downloads for video")
            actions.append(Action(title: downloadActionTitle, image: Action.Image.aggregatedDownload) {
                SlidesPersistenceManager.shared.startDownload(with: slidesURL, for: self)
                StreamPersistenceManager.shared.startDownload(with: streamURL, for: self)
            })
        }

        if streamDownloadState == .pending || streamDownloadState == .downloading, slidesDownloadState == .pending || slidesDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.combined-download-action.stop-download.title",
                                                     comment: "stop all downloads for video")
            actions.append(Action(title: abortActionTitle, image: Action.Image.stop) {
                SlidesPersistenceManager.shared.cancelDownload(for: self)
                StreamPersistenceManager.shared.cancelDownload(for: self)
            })
        }

        if streamDownloadState == .downloaded, slidesDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.combined-download-action.delete-download.title",
                                                      comment: "delete all downloads for video")
            actions.append(Action(title: deleteActionTitle, image: Action.Image.delete) {
                SlidesPersistenceManager.shared.deleteDownload(for: self)
                StreamPersistenceManager.shared.deleteDownload(for: self)
            })
        }

        return actions
    }
}

struct Action {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    enum Image {
        static var download: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "square.and.arrow.down")
            } else {
                return nil
            }
        }

        static var aggregatedDownload: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "square.and.arrow.down.on.square")
            } else {
                return nil
            }
        }

        static var stop: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "xmark.circle")
            } else {
                return nil
            }
        }

        static var delete: UIImage? {
            if #available(iOS 13, *) {
                return UIImage(systemName: "trash")
            } else {
                return nil
            }
        }
    }

}

extension UIAlertAction {

    convenience init(action: Action) {
        self.init(title: action.title, style: .default, handler: { _ in action.handler() })
    }

}

@available(iOS 13.0, *)
extension UIAction {

    convenience init(action: Action) {
        self.init(title: action.title, image: action.image, handler: { _ in action.handler() })
    }

}
