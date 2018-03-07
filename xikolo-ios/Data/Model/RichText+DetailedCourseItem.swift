//
//  RichText+DetailedCourseItem.swift
//  xikolo-ios
//
//  Created by Max Bothe on 20/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

extension RichText: DetailedCourseItem {

    static var contentType: String {
        return "rich_text"
    }

    var detailedText: String? {
        let words = self.text?.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        guard let wordcount = words?.count else {
            return nil
        }
        var calendar = Calendar.current
        calendar.locale = Locale.current
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute]
        formatter.zeroFormattingBehavior = [.pad]
        guard let durationText = formatter.string(from: ceil(Double(wordcount)/200)*60) else {
            return nil
        }
        return "~\(durationText)"
    }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncRichTexts(forCourse: course)
    }

}
