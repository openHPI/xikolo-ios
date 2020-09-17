//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class AnnouncementListViewController: CustomWidthTableViewController {

    private var dataSource: CoreDataTableViewDataSourceWrapper<Announcement>!
    private var relationshipKeyPathsObserver: RelationshipKeyPathsObserver<Announcement>?

    weak var scrollDelegate: CourseAreaScrollDelegate?

    var course: Course?

    private lazy var actionButton: UIBarButtonItem = {
        let markAllAsReadActionTitle = NSLocalizedString("announcement.alert.mark all as read",
                                                         comment: "alert action title to mark all announcements as read")
        let markAllAsReadAction = Action(title: markAllAsReadActionTitle) {
            AnnouncementHelper.markAllAsVisited()
        }

        let item = UIBarButtonItem.circularItem(
            with: R.image.navigationBarIcons.dots(),
            target: self,
            menuActions: [[markAllAsReadAction]]
        )

        item.accessibilityLabel = NSLocalizedString(
            "accessibility-label.announcements.navigation-bar.item.actions",
            comment: "Accessibility label for actions button in navigation bar of the course card view"
        )

        return item
    }()

    override func viewDidLoad() {
        self.view.preservesSuperviewLayoutMargins = true

        super.viewDidLoad()

        self.addRefreshControl()

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
        self.dataSource = CoreDataTableViewDataSource.dataSource(for: self.tableView,
                                                                 fetchedResultsController: resultsController,
                                                                 cellReuseIdentifier: reuseIdentifier,
                                                                 delegate: self)
        self.relationshipKeyPathsObserver = RelationshipKeyPathsObserver(for: Announcement.self,
                                                                         managedObjectContext: resultsController.managedObjectContext,
                                                                         keyPaths: [#keyPath(Announcement.course.enrollment)])

        self.refresh()
        self.setupEmptyState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.createEvent(.visitedAnnouncementList, on: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calculatePreferredSize()
    }

    private func calculatePreferredSize() {
        self.preferredContentSize = self.tableView.contentSize
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

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.announcements.title", comment: "title for empty announcement list")
    }

    var emptyStateDetailText: String? {
        return NSLocalizedString("empty-view.announcements.description", comment: "description for empty announcement list")
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
