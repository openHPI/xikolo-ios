//
//  CourseItem+DetailedCourseItem.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

extension Video: DetailedCourseItem {

    private static let videoDurationFormatter: DateComponentsFormatter = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()

    static var contentType: String {
        return "video"
    }

    var detailedText: String? {
        let timeInterval = TimeInterval(self.duration)
        guard timeInterval > 0 else {
            return nil
        }

        return Video.videoDurationFormatter.string(from: timeInterval)
    }

    var detailedIcons: [(image: UIImage, color: UIColor)] {
        var icons: [(image: UIImage, color: UIColor)] = []

        let videoIconColor: UIColor = self.isAvailableOffline ? .black : .lightGray
        if let videoIcon = UIImage(named: "download-video") {
            icons.append((image: videoIcon, color: videoIconColor))
        }

        if self.slidesURL != nil, let slidesIcon = UIImage(named: "download-spread") {
            icons.append((image: slidesIcon, color: .lightGray))
        }

        return icons
    }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncVideos(forCourse: course)
    }

}
