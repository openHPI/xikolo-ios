//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

enum DownloadState: String {
    case notDownloaded  // not downloaded at all
    case pending  // waiting for downloaded to start
    case downloading  // download in progress
    case downloaded  // downloaded and saved on disk

    static let didChangeNotification = Notification.Name("de.xikolo.ios.download.stateChanged")
}

enum DownloadProgress {
    static let didChangeNotification = Notification.Name("de.xikolo.ios.download.progressChanged")
}

enum DownloadNotificationKey {
    static let resourceId = "ResourceIdKey"
    static let downloadState = "ResourceDownloadStateKey"
    static let downloadProgress = "ResourceDownloadProgressKey"
    static let downloadType = "DownloadTypeKey"
}

enum LastVideoProgress {
    static let didChangeNotification = Notification.Name("de.xikolo.ios.video.lastPositionChanged")
}
