//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import DZNEmptyDataSet
import SafariServices
import UIKit

class CourseProgressListViewController: UITableViewController {

    var course: Course!

    // array available sections and corresponding points

    weak var scrollDelegate: CourseAreaScrollDelegate?

    override func viewDidLoad() {

        super.viewDidLoad()
        CourseProgressHelper.syncProgress(forCourse: self.course)

    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidEndDecelerating(scrollView)
    }

}

extension CourseProgressListViewController: CourseAreaViewController {

    var area: CourseArea {
        return .progress
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.course = course
        self.scrollDelegate = delegate
    }
}

extension CourseProgressListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseProgressHelper.syncProgress(forCourse: self.course).asVoid()
    }

}
