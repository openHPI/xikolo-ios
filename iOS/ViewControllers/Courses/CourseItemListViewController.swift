//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import DZNEmptyDataSet
import UIKit

class CourseItemListViewController: UITableViewController {
    typealias Resource = CourseItem

    var course: Course!

    var resultsController: NSFetchedResultsController<CourseItem>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseItem>!

    var contentToBePreloaded: [DetailedCourseItem.Type] = [Video.self, RichText.self]
    var isPreloading = false
    var inOfflineMode = ReachabilityHelper.connection == .none {
        didSet {
            if oldValue != self.inOfflineMode {
                self.tableView.reloadData()
            }
        }
    }

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // register custom section header view
        self.tableView.register(R.nib.courseItemHeader(), forHeaderFooterViewReuseIdentifier: R.nib.courseItemHeader.name)

        var separatorInsetLeft: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            self.tableView.separatorInsetReference = .fromAutomaticInsets
        } else {
            separatorInsetLeft += 15.0
        }

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: separatorInsetLeft, bottom: 0, right: 0)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)

        self.setupEmptyState()
        self.navigationItem.title = self.course.title

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.courseItemCell.identifier
        let request = CourseItemHelper.FetchRequest.orderedCourseItems(forCourse: course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.position") // must be the first sort descriptor
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: reuseIdentifier)

        let configuration = CourseItemListViewConfiguration(tableViewController: self).wrapped
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        self.refresh()

        do {
            try resultsController.performFetch()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        let contentPreloadOption = UserDefaults.standard.contentPreloadSetting
        let preloadingWanted = contentPreloadOption == .always || (contentPreloadOption == .wifiOnly && ReachabilityHelper.connection == .wifi)
        self.isPreloading = preloadingWanted && !self.contentToBePreloaded.isEmpty

        guard UserProfileHelper.isLoggedIn else {
            stopRefreshControl()
            return
        }

        CourseItemHelper.syncCourseItems(forCourse: self.course).onSuccess { _ in
            if preloadingWanted {
                self.preloadCourseContent()
            }
        }.onComplete { _ in
            stopRefreshControl()
        }
    }

    func showItem(_ item: CourseItem) {
        CourseItemHelper.markAsVisited(item)
        let context = [
            "content_type": item.contentType,
            "section_id": item.section?.id,
            "course_id": self.course.id,
        ]
        TrackingHelper.shared.createEvent(.visitedItem, resourceType: .item, resourceId: item.id, context: context)

        switch item.contentType {
        case "video"?:
            self.performSegue(withIdentifier: R.segue.courseItemListViewController.showVideo, sender: item)
        case "rich_text"?:
            self.performSegue(withIdentifier: R.segue.courseItemListViewController.showRichtext, sender: item)
        default:
            self.performSegue(withIdentifier: R.segue.courseItemListViewController.showCourseItem, sender: item)
        }
    }

    @objc func reachabilityChanged() {
        self.inOfflineMode = ReachabilityHelper.connection == .none
    }

    func preloadCourseContent() {
        self.contentToBePreloaded.traverse { contentType in
            return contentType.preloadContent(forCourse: self.course)
        }.onComplete { _ in
            self.isPreloading = false
        }
    }

    func showProctoringDialog(onComplete completionBlock: @escaping () -> Void) {
        let alertTitle = NSLocalizedString("course-item.proctoring.alert.title", comment: "title for proctoring alert")
        let alertMessage = NSLocalizedString("course-item.proctoring.alert.message", comment: "message for proctoring alert")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let confirmTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default))

        self.present(alert, animated: true, completion: completionBlock)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let courseItem = sender as? CourseItem else {
            log.debug("Sender is not a course item")
            super.prepare(for: segue, sender: sender)
            return
        }

        if let typedInfo = R.segue.courseItemListViewController.showVideo(segue: segue) {
            typedInfo.destination.courseItem = courseItem
        } else if let typedInfo = R.segue.courseItemListViewController.showCourseItem(segue: segue) {
            typedInfo.destination.courseItem = courseItem
        } else if let typedInfo = R.segue.courseItemListViewController.showRichtext(segue: segue) {
            typedInfo.destination.courseItem = courseItem
        }
    }

}

extension CourseItemListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.resultsController.object(at: indexPath)
        if item.proctored && (self.course.enrollment?.proctored ?? false) {
            self.showProctoringDialog {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            self.showItem(item)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseItemHeader.name) as? CourseItemHeader else {
            return nil
        }

        let visualIndexPath = IndexPath(row: 0, section: section)
        guard let (controller, indexPath) = self.resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: visualIndexPath) else {
            return nil
        }

        guard let section = controller.object(at: indexPath).section else {
            return nil
        }

        header.configure(for: section, inOfflineMode: self.inOfflineMode)
        header.delegate = self

        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}

class CourseItemListViewConfiguration: TableViewResultsControllerConfiguration {
    weak var tableViewController: CourseItemListViewController?

    init(tableViewController: CourseItemListViewController) {
        self.tableViewController = tableViewController
    }

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<CourseItem>, indexPath: IndexPath) {
        let cell = cell.require(toHaveType: CourseItemCell.self, hint: "CourseItemListViewController requires cell of type CourseItemCell")
        let item = controller.object(at: indexPath)
        cell.delegate = self.tableViewController

        cell.configure(for: item)
    }

}

extension CourseItemListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.course-content.title", comment: "title for empty course content list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.course-content.description",
                                            comment: "description for empty course content list")
        return NSAttributedString(string: description)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.refresh()
    }

}

extension CourseItemListViewController: UserActionsDelegate {

    func showAlert(with actions: [UIAlertAction], withTitle title: String? = nil, on anchor: UIView) {
        guard !actions.isEmpty else { return }

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = anchor
        alert.popoverPresentationController?.sourceRect = anchor.bounds.insetBy(dx: -4, dy: -4)

        for action in actions {
            alert.addAction(action)
        }

        alert.addCancelAction()

        self.present(alert, animated: true)
    }

    func showAlertSpinner(title: String?, task: () -> Future<Void, XikoloError>) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        let alert = UIAlertController(spinnerTitled: title, preferredStyle: .alert)
        alert.addCancelAction { _ in
            promise.failure(.userCanceled)
        }

        self.present(alert, animated: true)

        task().onComplete { result in
            promise.tryComplete(result)
            alert.dismiss(animated: true)
        }

        return promise.future
    }

}

extension CourseItemListViewController: CourseContentViewController {

    func configure(for course: Course) {
        self.course = course
    }

}
