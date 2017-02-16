//
//  NotificationKeys.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 08.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class NotificationKeys: NSObject {

    static let loginSuccessfulKey = Notification.Name("de.hpi.open.loginsuccessful")
    static let logoutSuccessfulKey = Notification.Name("de.hpi.open.logoutsuccessful")

    static let dropdownCourseContentKey = Notification.Name("de.hpi.open.dropdown.courseContent")

}
