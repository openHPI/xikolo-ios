//
//  DropdownTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 13.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class DropdownTableViewController: UITableViewController {

    var course: Course!

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userList = [NotificationKeys.dropdownCourseContentKey:indexPath.row]
        NotificationCenter.default.post(name: NotificationKeys.dropdownCourseContentKey, object: self, userInfo: userList)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 4 {
            cell.enable(course.hasEnrollment && course.accessible)
        }
    }

}
