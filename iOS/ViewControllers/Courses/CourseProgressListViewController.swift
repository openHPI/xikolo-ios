//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import SafariServices
import UIKit
import CoreData

class CourseProgressListViewController: UITableViewController {

    private var dataSource: CoreDataTableViewDataSource<CourseProgressListViewController>!
    var course: Course!

    // array available sections and corresponding points

    weak var scrollDelegate: CourseAreaScrollDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()

        // setup table view data
        let request: NSFetchRequest<SectionProgress>
        request = SectionProgressHelper.FetchRequest.sectionProgresses(forCourse: course)

        let reuseIdentifier = R.reuseIdentifier.sectionProgressCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.refresh()
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

extension CourseProgressListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: SectionProgressCell, for object: SectionProgress) {
        cell.configure(for: object, showCourseTitle: self.course == nil)
        //cell.textLabel?.text = object.title
    }

}
