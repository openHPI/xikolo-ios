//
//  LastCourseActivityViewController.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 16.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit

class CourseActivityViewController : UITableViewController {

    weak var delegate: CourseActivityViewControllerDelegate?

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseActivityCell") as! CourseActivityRow
        return cell
    }

    func tableViewHeight() -> CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        delegate?.changedCourseActivityTableViewHeight(tableViewHeight())
    }

}


protocol CourseActivityViewControllerDelegate: class {

    func changedCourseActivityTableViewHeight(height: CGFloat)

}
