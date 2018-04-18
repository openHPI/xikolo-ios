//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class DropdownListViewController: UITableViewController {

    var course: Course!

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userList = [NotificationKeys.dropdownCourseContentKey: indexPath.row]
        NotificationCenter.default.post(name: NotificationKeys.dropdownCourseContentKey, object: self, userInfo: userList)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row != 2 {
            cell.enable(course.hasEnrollment && course.accessible)
        }
    }

}
