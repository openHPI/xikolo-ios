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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        delegate?.changedCourseActivityTableViewHeight(tableViewHeight())
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseActivityCell") as! CourseActivityRow
        return cell
    }

    func tableViewHeight() -> CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }

}


protocol CourseActivityViewControllerDelegate: class {

    func changedCourseActivityTableViewHeight(_ height: CGFloat)

}
