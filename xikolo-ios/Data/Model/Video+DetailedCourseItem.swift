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

    var detailedContent: [DetailedData] {
        var content: [DetailedData] = []

        if let durationText = self.durationText {
            content.append(DetailedData(text: durationText, isOfflineAvailable: self.isAvailableOffline, showOfflineIcon: true))
        }

        if let slidesText = self.slidesText {
            content.append(DetailedData(text: slidesText, isOfflineAvailable: false, showOfflineIcon: true))
        }

        return content
    }

    private var durationText: String? {
        let timeInterval = TimeInterval(self.duration)
        guard timeInterval > 0 else {
            return nil
        }

        return Video.videoDurationFormatter.string(from: timeInterval)
    }

    private var slidesText: String? {
        guard self.slidesURL != nil else { return nil }
        return NSLocalizedString("course-item.video.slides.label", comment: "Shown in course content list")
    }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncVideos(forCourse: course)
    }

}
