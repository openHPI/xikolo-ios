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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userList = [NotificationKeys.dropdownCourseContentKey:indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.dropdownCourseContentKey, object: self, userInfo: userList)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 2 {
            cell.enable(course.enrollment != nil)
        }
    }

}
