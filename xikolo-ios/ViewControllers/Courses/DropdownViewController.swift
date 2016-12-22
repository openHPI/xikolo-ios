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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "EmbedDropdownTableView"?:
            let vc = segue.destinationViewController as! DropdownTableViewController
            vc.course = course
        default:
            break
        }
    }

}
