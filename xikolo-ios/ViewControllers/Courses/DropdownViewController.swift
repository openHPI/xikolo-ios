//
//  DropdownViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 29.10.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class DropdownViewController: UIViewController {

    var course: Course!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EmbedCourseContentChoice"?:
            let vc = segue.destination.require(toHaveType: DropdownTableViewController.self)
            vc.course = course
        default:
            break
        }
    }

}
