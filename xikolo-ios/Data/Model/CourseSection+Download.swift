//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension CourseSection {

    private struct ItemCounter {
        var numberOfDownloadableVideos = 0
        var numberOfDownloadingVideos = 0
        var numberOfDownloadedVideos = 0
    }

    private var videos: [Video] {
        return self.items.compactMap { item in
            return item.content as? Video
        }
    }

    var allVideosPreloaded: Bool {
        return !self.items.contains { item in
            return item.contentType == Video.contentType && item.content == nil
        }
    }

    var hasUserActions: Bool {
        return self.items.contains { item in
            return item.contentType == Video.contentType
        }
    }

    var userActions: [UIAlertAction] {
        var actions: [UIAlertAction] = []
        var itemCounter = ItemCounter()

        self.items.compactMap { item in
            return item.content as? Video
        }.forEach { video in
            if video.localFileBookmark != nil {
                itemCounter.numberOfDownloadedVideos += 1
            } else if [.pending, .downloading].contains(StreamPersistenceManager.shared.downloadState(for: video)) {
                itemCounter.numberOfDownloadingVideos += 1
            } else {
                itemCounter.numberOfDownloadableVideos += 1
            }
        }

        if itemCounter.numberOfDownloadableVideos > 0, ReachabilityHelper.connection != .none {
            let downloadActionTitle = NSLocalizedString("course-section.video-download-action.start-downloads.title",
                                                        comment: "start video downloads for all videos in section")
            actions.append(UIAlertAction(title: downloadActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.startDownloads(for: self)
            })
        }

        if itemCounter.numberOfDownloadedVideos > 0 {
            let deleteActionTitle = NSLocalizedString("course-section.video-download-action.delete-videos.title",
                                                      comment: "delete all downloaded videos downloads in section")
            actions.append(UIAlertAction(title: deleteActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.deleteDownloads(for: self)
            })
        }

        if itemCounter.numberOfDownloadingVideos > 0 {
            let stopActionTitle = NSLocalizedString("course-section.video-download-action.stop-downloads.title",
                                                    comment: "stop all video downloads in section")
            actions.append(UIAlertAction(title: stopActionTitle, style: .default) { _ in
                StreamPersistenceManager.shared.cancelDownloads(for: self)
            })
        }

        return actions
    }

}
