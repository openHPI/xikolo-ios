//
//  RichText.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Spine

class RichText : Content {

    override func iconName() -> String {
        return "rich_text"
    }

}

class RichTextSpine : ContentSpine {

    var text: String?

    override class var cdType: BaseModel.Type {
        return RichText.self
    }

    override class var resourceType: ResourceType {
        return "rich-texts"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "text": Attribute(),
        ])
    }

}


extension RichText: DetailedContent {

    var detailedInformation: String? {

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

    static func preloadContentFor(course: Course) -> Future<[CourseItem], XikoloError> {
        return CourseItemHelper.syncRichTextsFor(course: course)
    }

}
