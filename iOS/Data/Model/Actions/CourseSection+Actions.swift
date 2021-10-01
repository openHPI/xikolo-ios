//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

extension CourseSection {

    private struct DownloadItemCounter {
        var numberOfDownloadableItems = 0
        var numberOfDownloadingItems = 0
        var numberOfDownloadedItems = 0
    }

    private struct ItemCounter {
        var stream = DownloadItemCounter()
        var slides = DownloadItemCounter()
    }

    private static var actionDispatchQueue: DispatchQueue {
        return DispatchQueue(label: "section-actions", qos: .userInitiated)
    }

    var allVideosPreloaded: Bool {
        return !self.items.contains { item in
            return item.contentType == Video.contentType && item.content == nil
        }
    }

    var hasActions: Bool {
        return self.items.contains { item in
            return item.contentType == Video.contentType
        }
    }

    var actions: [Action] {
        var actions: [Action] = []
        var itemCounter = ItemCounter()

        self.items.compactMap { item in
            return item.content as? Video
        }.forEach { video in
            if video.localFileBookmark != nil {
                itemCounter.stream.numberOfDownloadedItems += 1
            } else if [.pending, .downloading].contains(StreamPersistenceManager.shared.downloadState(for: video)) {
                itemCounter.stream.numberOfDownloadingItems += 1
            } else if video.streamURLForDownload != nil {
                itemCounter.stream.numberOfDownloadableItems += 1
            }

            if video.localSlidesBookmark != nil {
                itemCounter.slides.numberOfDownloadedItems += 1
            } else if [.pending, .downloading].contains(SlidesPersistenceManager.shared.downloadState(for: video)) {
                itemCounter.slides.numberOfDownloadingItems += 1
            } else if video.slidesURL != nil {
                itemCounter.slides.numberOfDownloadableItems += 1
            }
        }

        // user actions for stream

        if itemCounter.stream.numberOfDownloadableItems > 0, ReachabilityHelper.hasConnection {
            let downloadActionTitle = NSLocalizedString("course-section.stream-download-action.start-downloads.title",
                                                        comment: "start stream downloads for all videos in section")
            actions.append(Action(title: downloadActionTitle, image: Action.Image.aggregatedDownload) {
                Self.actionDispatchQueue.async {
                    StreamPersistenceManager.shared.startDownloads(for: self)
                }
            })
        }

        if itemCounter.stream.numberOfDownloadedItems > 0 {
            let deleteActionTitle = NSLocalizedString("course-section.stream-download-action.delete-downloads.title",
                                                      comment: "delete all downloaded streams downloads in section")
            actions.append(Action(title: deleteActionTitle, image: Action.Image.delete) {
                Self.actionDispatchQueue.async {
                    StreamPersistenceManager.shared.deleteDownloads(for: self)
                }
            })
        }

        if itemCounter.stream.numberOfDownloadingItems > 0 {
            let stopActionTitle = NSLocalizedString("course-section.stream-download-action.stop-downloads.title",
                                                    comment: "stop all stream downloads in section")
            actions.append(Action(title: stopActionTitle, image: Action.Image.stop) {
                Self.actionDispatchQueue.async {
                    StreamPersistenceManager.shared.cancelDownloads(for: self)
                }
            })
        }

        // user actions for slides

        if itemCounter.slides.numberOfDownloadableItems > 0, ReachabilityHelper.hasConnection {
            let downloadActionTitle = NSLocalizedString("course-section.slides-download-action.start-downloads.title",
                                                        comment: "start slides downloads for all videos in section")
            actions.append(Action(title: downloadActionTitle, image: Action.Image.aggregatedDownload) {
                Self.actionDispatchQueue.async {
                    SlidesPersistenceManager.shared.startDownloads(for: self)
                }
            })
        }

        if itemCounter.slides.numberOfDownloadedItems > 0 {
            let deleteActionTitle = NSLocalizedString("course-section.slides-download-action.delete-downloads.title",
                                                      comment: "delete all downloaded slides downloads in section")
            actions.append(Action(title: deleteActionTitle, image: Action.Image.delete) {
                Self.actionDispatchQueue.async {
                    SlidesPersistenceManager.shared.deleteDownloads(for: self)
                }
            })
        }

        if itemCounter.slides.numberOfDownloadingItems > 0 {
            let stopActionTitle = NSLocalizedString("course-section.slides-download-action.stop-downloads.title",
                                                    comment: "stop all slides downloads in section")
            actions.append(Action(title: stopActionTitle, image: Action.Image.stop) {
                Self.actionDispatchQueue.async {
                    SlidesPersistenceManager.shared.cancelDownloads(for: self)
                }
            })
        }

        // combined user actions

        if itemCounter.stream.numberOfDownloadableItems > 0, itemCounter.slides.numberOfDownloadableItems > 0, ReachabilityHelper.hasConnection {
            let downloadActionTitle = NSLocalizedString("course-section.combined-download-action.start-downloads.title",
                                                        comment: "start all downloads for all videos in section")
            actions.append(Action(title: downloadActionTitle, image: Action.Image.aggregatedDownload) {
                Self.actionDispatchQueue.async {
                    StreamPersistenceManager.shared.startDownloads(for: self)
                    SlidesPersistenceManager.shared.startDownloads(for: self)
                }
            })
        }

        if itemCounter.stream.numberOfDownloadedItems > 0, itemCounter.slides.numberOfDownloadedItems > 0 {
            let deleteActionTitle = NSLocalizedString("course-section.combined-download-action.delete-downloads.title",
                                                      comment: "delete all downloads in section")
            actions.append(Action(title: deleteActionTitle, image: Action.Image.delete) {
                Self.actionDispatchQueue.async {
                    StreamPersistenceManager.shared.deleteDownloads(for: self)
                    SlidesPersistenceManager.shared.deleteDownloads(for: self)
                }
            })
        }

        if itemCounter.stream.numberOfDownloadingItems > 0, itemCounter.slides.numberOfDownloadingItems > 0 {
            let stopActionTitle = NSLocalizedString("course-section.combined-download-action.stop-downloads.title",
                                                    comment: "stop all downloads in section")
            actions.append(Action(title: stopActionTitle, image: Action.Image.stop) {
                Self.actionDispatchQueue.async {
                    StreamPersistenceManager.shared.cancelDownloads(for: self)
                    SlidesPersistenceManager.shared.cancelDownloads(for: self)
                }
            })
        }

        return actions
    }

}
