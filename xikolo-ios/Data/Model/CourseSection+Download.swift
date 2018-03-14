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
        return self.items.flatMap { item in
            return item.content as? Video
        }
    }

    var hasUserActions: Bool {
        return self.items.contains { item in
            return item.content is Video
        }
    }

    var userActions: [UIAlertAction] {
        var actions: [UIAlertAction] = []
        var itemCounter = ItemCounter()

        self.items.flatMap { item in
            return item.content as? Video
        }.forEach { video in
            if video.localFileBookmark != nil {
                itemCounter.numberOfDownloadedVideos += 1
            } else if [.pending, .downloading].contains(VideoPersistenceManager.shared.downloadState(for: video)) {
                itemCounter.numberOfDownloadingVideos += 1
            } else {
                itemCounter.numberOfDownloadableVideos += 1
            }
        }

        if itemCounter.numberOfDownloadableVideos > 0, ReachabilityHelper.connection != .none {
            actions.append(UIAlertAction(title: "download all videos", style: .default) { _ in
                print("download all videos in section")
                VideoPersistenceManager.shared.downloadVideos(for: self)
            })
        }

        if itemCounter.numberOfDownloadedVideos > 0 {
            actions.append(UIAlertAction(title: "delete all videos", style: .default) { _ in
                print("delete all videos in section")
                VideoPersistenceManager.shared.deleteVideos(for: self)
            })
        }

        if itemCounter.numberOfDownloadingVideos > 0 {
            actions.append(UIAlertAction(title: "stop all video downloads", style: .default) { _ in
                print("stop all video downloads in section")
                VideoPersistenceManager.shared.cancelVideoDownloads(for: self)
            })
        }

        return actions
    }

}
