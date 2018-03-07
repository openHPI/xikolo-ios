//
//  DetailedContent.swift
//  xikolo-ios
//
//  Created by Max Bothe on 13/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

protocol DetailedCourseItem {

    static var contentType: String { get }

    var detailedContent: DetailedContent? { get }
    var detailedText: String? { get }
    var detailedIcons: [(image: UIImage, color: UIColor)] { get }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError>

}

extension DetailedCourseItem {

    var detailedContent: DetailedContent? {
        return DetailedContent(text: self.detailedText, icons: self.detailedIcons)
    }

    var detailedIcons: [(image: UIImage, color: UIColor)] {
        return []
    }

}

struct DetailedContent {

    let text: String?
    let icons: [(image: UIImage, color: UIColor)]

    var hasContent: Bool {
        return text != nil || !icons.isEmpty
    }

}
