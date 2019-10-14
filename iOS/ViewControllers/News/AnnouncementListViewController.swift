//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class AnnouncementListViewController: UITableViewController {

    private var dataSource: CoreDataTableViewDataSource<AnnouncementListViewController>!

    weak var scrollDelegate: CourseAreaScrollDelegate?

    var course: Course?

    @IBOutlet private var actionButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUIAfterLoginStateChanged),
                                               name: UserProfileHelper.loginStateDidChangeNotification,
                                               object: nil)

        self.updateUIAfterLoginStateChanged()

        // set to follow readable width when course is present
        self.tableView.cellLayoutMarginsFollowReadableWidth = self.course != nil

        // setup table view data
        let request: NSFetchRequest<Announcement>

        if let course = course {
            request = AnnouncementHelper.FetchRequest.announcements(forCourse: course)
        } else {
            request = AnnouncementHelper.FetchRequest.allAnnouncements
        }

        let reuseIdentifier = R.reuseIdentifier.announcementCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.refresh()
        self.setupEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.createEvent(.visitedAnnouncementList, on: self)
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
        self.tableView.emptyStateDelegate = self
        self.tableView.tableFooterView = UIView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let announcement = (sender as? Announcement).require(hint: "Sender must be Announcement")
        if let typedInfo = R.segue.announcementListViewController.showAnnouncement(segue: segue) {
            typedInfo.destination.configure(for: announcement, showCourseTitle: self.course == nil)
        }
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

    @objc private func updateUIAfterLoginStateChanged() {
        self.navigationItem.rightBarButtonItem = UserProfileHelper.shared.isLoggedIn ? self.actionButton : nil
    }

    @IBAction private func tappedActionButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender

        let markAllAsReadActionTitle = NSLocalizedString("announcement.alert.mark all as read", comment: "alert action title to mark all announcements as read")
        let markAllAsReadAction = UIAlertAction(title: markAllAsReadActionTitle, style: .default) { _ in
            AnnouncementHelper.markAllAsVisited()
        }

        alert.addAction(markAllAsReadAction)
        alert.addCancelAction()

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    @objc private func coreDataChange(notification: Notification) {
        guard notification.includesChanges(for: Enrollment.self, keys: [NSUpdatedObjectsKey, NSRefreshedObjectsKey]) else { return }
        self.tableView.reloadData()
    }

}

extension AnnouncementListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = self.dataSource.object(at: indexPath)
        self.performSegue(withIdentifier: R.segue.announcementListViewController.showAnnouncement, sender: announcement)
    }

}

extension AnnouncementListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: AnnouncementCell, for object: Announcement) {
        cell.configure(for: object, showCourseTitle: self.course == nil)
    }

}

extension AnnouncementListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        if let course = self.course {
            return AnnouncementHelper.syncAnnouncements(for: course).asVoid()
        } else {
            return AnnouncementHelper.syncAllAnnouncements().asVoid()
        }
    }

}

extension AnnouncementListViewController: EmptyStateDataSource, EmptyStateDelegate {

    var titleText: String? {
        return NSLocalizedString("empty-view.announcements.title", comment: "title for empty announcement list")
    }

    var detailText: String {
        return NSLocalizedString("empty-view.announcements.description", comment: "description for empty announcement list")
    }

//    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
//        self.refresh()
//    }

}

extension AnnouncementListViewController: CourseAreaViewController {

    var area: CourseArea {
        return .announcements
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.course = course
        self.scrollDelegate = delegate
    }

}
