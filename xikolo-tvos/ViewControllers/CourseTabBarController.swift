//
//  CourseTabBarController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class CourseTabBarController : UITabBarController {

    var course: Course!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barTintColor = Brand.tintColor

        if course.is_enrolled {
            // If the user is already enrolled, directly switch to learnings tab.
            selectedIndex = 1
        }
    }

}
