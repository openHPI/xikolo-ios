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

    var detailedContent: [DetailedData] { get }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError>

}

struct DetailedData {

    let text: String
    let isOfflineAvailable: Bool
    let showOfflineIcon: Bool

}
