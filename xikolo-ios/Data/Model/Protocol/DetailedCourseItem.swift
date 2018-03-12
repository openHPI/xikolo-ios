//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

protocol DetailedCourseItem {

    static var contentType: String { get }

    var detailedContent: [DetailedData] { get }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError>

}

enum DetailedData {

    case text(readingTime: TimeInterval)  // if we have this, it's always downloaded
    case video(duration: TimeInterval, downloaded: Bool)
    case slides(downloaded: Bool)

    var downloaded: Bool {
        switch self {
        case .text(readingTime: _):
            return true
        case let .video(duration: _, downloaded: downloaded):
            return downloaded
        case let .slides(downloaded: downloaded):
            return downloaded
        }
    }

    var shownDownloadedIcon: Bool {
        switch self {
        case .text(readingTime: _):
            return false
        case let .video(duration: _, downloaded: downloaded):
            return downloaded
        case let .slides(downloaded: downloaded):
            return downloaded
        }
    }

}
