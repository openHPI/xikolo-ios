//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import DZNEmptyDataSet
import UIKit

class AnnouncementsListViewController: UITableViewController {

    private var dataSource: CoreDataTableViewDataSource<AnnouncementsListViewController>!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    var course: Course?

    @IBOutlet private var actionButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUIAfterLoginStateChanged),
                                               name: UserProfileHelper.loginStateDidChangeNotification,
                                               object: nil)

        self.updateUIAfterLoginStateChanged()

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

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

        self.setupEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.shared.createEvent(.visitedAnnouncementList)
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow

        let refreshFuture: Future<SyncEngine.SyncMultipleResult, XikoloError>
        if let course = self.course {
            refreshFuture = AnnouncementHelper.shared.syncAnnouncements(for: course)
        } else {
            refreshFuture = AnnouncementHelper.shared.syncAllAnnouncements()
        }

        refreshFuture.onComplete { _ in
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let announcement = (sender as? Announcement).require(hint: "Sender must be Announcement")
        if let typedInfo = R.segue.announcementsListViewController.showAnnouncement(segue: segue) {
            typedInfo.destination.configure(for: announcement, showCourseTitle: self.course == nil)
        }
    }

    @objc private func updateUIAfterLoginStateChanged() {
        self.navigationItem.rightBarButtonItem = UserProfileHelper.shared.isLoggedIn ? self.actionButton : nil
    }

    @IBAction func tappedActionButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender

        let markAllAsReadActionTitle = NSLocalizedString("announcement.alert.mark all as read", comment: "alert action title to mark all announcements as read")
        let markAllAsReadAction = UIAlertAction(title: markAllAsReadActionTitle, style: .default) { _ in
            AnnouncementHelper.shared.markAllAsVisited()
        }

        alert.addAction(markAllAsReadAction)
        alert.addCancelAction()

        self.present(alert, animated: true)
    }
}

extension AnnouncementsListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = self.dataSource.object(at: indexPath)
        self.performSegue(withIdentifier: R.segue.announcementsListViewController.showAnnouncement, sender: announcement)
    }

}

extension AnnouncementsListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: AnnouncementCell, for object: Announcement) {
        cell.configure(for: object, showCourseTitle: self.course == nil)
    }

}

extension AnnouncementsListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.announcements.title", comment: "title for empty announcement list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.announcements.description", comment: "description for empty announcement list")
        return NSAttributedString(string: description)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.refresh()
    }

}

extension AnnouncementsListViewController: CourseAreaViewController {

    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate) {
        self.course = course
    }

}
