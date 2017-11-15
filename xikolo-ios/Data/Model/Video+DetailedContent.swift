//
//  CourseItem+DetailedContent.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import BrightFutures
import Foundation

extension Video: DetailedContent {

    var detailedInformation: String? {
        let textComponents = [self.durationText, self.slidesText].flatMap { $0 }
        guard !textComponents.isEmpty else {
            return nil
        }

        return textComponents.joined(separator: " \u{B7} ")  // Unicode 00B7 is ·
    }

    private var durationText: String? {
        let timeInterval = TimeInterval(self.duration)
        guard timeInterval > 0 else {
            return nil
        }

        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: timeInterval)
    }

    private var slidesText: String? {
        guard self.slidesURL != nil else { return nil }
        return NSLocalizedString("course-item.video.slides.label", comment: "Shown in course content list")
    }

    static func preloadContentFor(course: Course) -> Future<[CourseItem], XikoloError> {
        return CourseItemHelper.syncVideos(forCourse: course)
    }

}
