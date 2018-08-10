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

    var resultsController: NSFetchedResultsController<Announcement>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<Announcement>!

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

        self.setupRefreshControl()

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
        TrackingHelper.shared.createEvent(.visitedAnnouncementList)
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
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

extension AnnouncementsListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        if let course = self.course {
            return AnnouncementHelper.shared.syncAnnouncements(for: course).asVoid()
        } else {
            return AnnouncementHelper.shared.syncAllAnnouncements().asVoid()
        }
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
