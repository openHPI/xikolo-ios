//
//  NotificationKeys.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 08.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

struct NotificationKeys {

    static let loginStateChangedKey = Notification.Name("de.hpi.open.loginStateChanged")

    static let createdEnrollmentKey = Notification.Name("de.hpi.open.createdEnrollment")
    static let deletedEnrollmentKey = Notification.Name("de.hpi.open.deletedEnrollment")

    static let dropdownCourseContentKey = Notification.Name("de.hpi.open.dropdown.courseContent")

}
