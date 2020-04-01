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

struct Action {
    let title: String
    let image: UIImage?
    let handler: () -> Void
}

extension Video {

    var streamURLForDownload: URL? {
        return self.singleStream?.hlsURL
    }

    private var availableActions: [Action] {
        return [self.streamUserAction, self.slidesUserAction].compactMap { $0 } + self.combinedActions
    }

    var alertActions: [UIAlertAction] {
        return self.availableActions.map { action in
            self.convert(action: action)
        }
    }

    @available(iOS 13.0, *)
    var actions: [UIAction] {
        return self.availableActions.map { action in
            return UIAction(title: action.title, image: action.image) { _ in
                action.handler()
            }
        }
    }

    func convert(action: Action) -> UIAlertAction {
        return UIAlertAction(title: action.title, style: .default) { _ in
            action.handler()
        }
    }

    var streamAlertAction: UIAlertAction? {
        guard let streamUserAction = self.streamUserAction else { return nil }
        return convert(action: streamUserAction)
    }

    var slidesAlertAction: UIAlertAction? {
        guard let slidesUserAction = self.slidesUserAction else { return nil }
        return convert(action: slidesUserAction)
    }

    var streamUserAction: Action? {
        let isOffline = !ReachabilityHelper.hasConnection
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)

        if let url = self.streamURLForDownload, streamDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.stream-download-action.start-download.title",
                                                        comment: "start download of stream for video")

            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "arrow.down.left.video")
                } else {
                    return nil
                }
            }()

            return Action(title: downloadActionTitle, image: image) {
                StreamPersistenceManager.shared.startDownload(with: url, for: self)
            }
        }

        if streamDownloadState == .pending || streamDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.stream-download-action.stop-download.title",
                                                     comment: "stop stream download for video")
            let image: UIImage? = {
                       if #available(iOS 13, *) {
                           return UIImage(systemName: "stop.circle")
                       } else {
                           return nil
                       }
                   }()

            return Action(title: abortActionTitle, image: image) {
                StreamPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if streamDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.stream-download-action.delete-download.title",
                                                      comment: "delete stream download for video")
            let image: UIImage? = {
                       if #available(iOS 13, *) {
                           return UIImage(systemName: "trash")
                       } else {
                           return nil
                       }
                   }()

            return Action(title: deleteActionTitle, image: image) {
                StreamPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

    var slidesUserAction: Action? {

        let isOffline = !ReachabilityHelper.hasConnection
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let url = self.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.slides-download-action.start-download.title",
                                                        comment: "start download of slides for video")
            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "arrow.down.doc")
                } else {
                    return nil
                }
            }()

            return Action(title: downloadActionTitle, image: image) {
                SlidesPersistenceManager.shared.startDownload(with: url, for: self)
            }

        }

        if  slidesDownloadState == .pending || slidesDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.slides-download-action.stop-download.title",
                                                     comment: "stop slides download for video")
            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "stop.circle")
                } else {
                    return nil
                }
            }()

            return Action(title: abortActionTitle, image: image) {
                SlidesPersistenceManager.shared.cancelDownload(for: self)
            }
        }

        if slidesDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.slides-download-action.delete-download.title",
                                                      comment: "delete slides download for video")
            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "trash")
                } else {
                    return nil
                }
            }()

            return Action(title: deleteActionTitle, image: image) {
                SlidesPersistenceManager.shared.deleteDownload(for: self)
            }
        }

        return nil
    }

    var combinedActions: [Action] {

        var actions: [Action] = []

        let isOffline = !ReachabilityHelper.hasConnection
        let streamDownloadState = StreamPersistenceManager.shared.downloadState(for: self)
        let slidesDownloadState = SlidesPersistenceManager.shared.downloadState(for: self)

        if let streamURL = self.streamURLForDownload, streamDownloadState == .notDownloaded,
            let slidesURL = self.slidesURL, slidesDownloadState == .notDownloaded, !isOffline {
            let downloadActionTitle = NSLocalizedString("course-item.combined-download-action.start-download.title",
                                                        comment: "start all downloads for video")
            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "square.and.arrow.down")
                } else {
                    return nil
                }
            }()

            actions.append(Action(title: downloadActionTitle, image: image) {
                SlidesPersistenceManager.shared.startDownload(with: slidesURL, for: self)
                StreamPersistenceManager.shared.startDownload(with: streamURL, for: self)
            })
        }

        if streamDownloadState == .pending || streamDownloadState == .downloading, slidesDownloadState == .pending || slidesDownloadState == .downloading {
            let abortActionTitle = NSLocalizedString("course-item.combined-download-action.stop-download.title",
                                                     comment: "stop all downloads for video")
            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "stop.circle")
                } else {
                    return nil
                }
            }()

            actions.append(Action(title: abortActionTitle, image: image) {
                SlidesPersistenceManager.shared.cancelDownload(for: self)
                StreamPersistenceManager.shared.cancelDownload(for: self)
            })
        }

        if streamDownloadState == .downloaded, slidesDownloadState == .downloaded {
            let deleteActionTitle = NSLocalizedString("course-item.combined-download-action.delete-download.title",
                                                      comment: "delete all downloads for video")
            let image: UIImage? = {
                if #available(iOS 13, *) {
                    return UIImage(systemName: "trash")
                } else {
                    return nil
                }
            }()

            actions.append(Action(title: deleteActionTitle, image: image) {
                SlidesPersistenceManager.shared.deleteDownload(for: self)
                StreamPersistenceManager.shared.deleteDownload(for: self)
            })
        }

        return actions
    }
}
