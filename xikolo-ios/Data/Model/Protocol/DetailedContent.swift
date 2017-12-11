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

protocol DetailedContent {

    var detailedInformation: String? { get }

    static func preloadContentFor(course: Course) -> Future<[NSManagedObjectID], XikoloError>

}
