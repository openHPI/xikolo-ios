//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import SafariServices
import UIKit

class CourseProgressViewController: UITableViewController {

    private var dataSource: CoreDataTableViewDataSource<CourseProgressViewController>!
    var course: Course!

    @IBOutlet private weak var courseProgressView: CourseProgressView!

    weak var scrollDelegate: CourseAreaScrollDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()
        self.setupEmptyState()

        // setup table view data
        let request = SectionProgressHelper.FetchRequest.sectionProgresses(forCourse: course)
        let reuseIdentifier = R.reuseIdentifier.sectionProgressCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.refresh()
        self.configureCourseProgress()
    }

    func configureCourseProgress() {
        let fetchRequest = CourseProgressHelper.FetchRequest.courseProgress(forCourse: self.course)
        let progress = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value
        self.courseProgressView.configure(for: progress)
        self.tableView.tableHeaderView?.isHidden = progress == nil
        self.tableView.resizeTableHeaderView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
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

extension CourseProgressViewController: CourseAreaViewController {

    var area: CourseArea {
        return .progress
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.course = course
        self.scrollDelegate = delegate
    }
}

extension CourseProgressViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseProgressHelper.syncProgress(forCourse: self.course).asVoid()
    }

    func didRefresh() {
        self.configureCourseProgress()
    }

}

extension CourseProgressViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: SectionProgressCell, for object: SectionProgress) {
        cell.configure(for: object, showCourseTitle: self.course == nil)
    }

}

extension CourseProgressViewController: EmptyStateDataSource, EmptyStateDelegate {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.course-progress.title", comment: "title for empty course progress view")
    }

    func didTapOnEmptyStateView() {
        self.refresh()
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
        self.tableView.emptyStateDelegate = self
        self.tableView.tableFooterView = UIView()
    }

}
