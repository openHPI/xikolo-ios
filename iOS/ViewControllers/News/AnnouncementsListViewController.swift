//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import DZNEmptyDataSet
import UIKit

class AnnouncementsListViewController: UITableViewController {

    var resultsController: NSFetchedResultsController<Announcement>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<Announcement>!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    var course: Course?

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // set to follow readable width when course is present
        self.tableView.cellLayoutMarginsFollowReadableWidth = self.course != nil

        // setup table view data
        var request: NSFetchRequest<Announcement>

        if let course = course {
            request = AnnouncementHelper.FetchRequest.announcements(forCourse: course)
        } else {
            request = AnnouncementHelper.FetchRequest.allAnnouncements
        }

        let reuseIdentifier = R.reuseIdentifier.announcementCell.identifier
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: reuseIdentifier)

        let configuration = AnnouncementsTableViewConfiguration(shouldShowCourseTitle: self.course == nil)
        let configurationWrapper = configuration.wrapped
        resultsControllerDelegateImplementation.configuration = configurationWrapper
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        self.refresh()

        do {
            try resultsController.performFetch()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }

        self.setupEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.createEvent(.visitedAnnouncementList)
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
            typedInfo.destination.announcement = announcement
            typedInfo.destination.showCourseTitle = self.course == nil
        }
    }

}

extension AnnouncementsListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = resultsController.object(at: indexPath)
        self.performSegue(withIdentifier: R.segue.announcementsListViewController.showAnnouncement, sender: announcement)
    }

}

struct AnnouncementsTableViewConfiguration: TableViewResultsControllerConfiguration {

    var shouldShowCourseTitle: Bool

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<Announcement>, indexPath: IndexPath) {
        let cell = cell.require(toHaveType: AnnouncementCell.self, hint: "AnnouncementsListViewController requires cells of type AnnouncementCell")
        let announcement = controller.object(at: indexPath)
        cell.configure(announcement, showCourseTitle: shouldShowCourseTitle)
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

extension AnnouncementsListViewController: CourseContentViewController {

    func configure(for course: Course) {
        self.course = course
    }

}
