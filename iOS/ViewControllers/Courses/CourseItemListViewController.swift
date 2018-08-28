//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import DZNEmptyDataSet
import UIKit

class CourseItemListViewController: UITableViewController {

    private var course: Course!
    private var dataSource: CoreDataTableViewDataSource<CourseItemListViewController>!

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

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50

        // register custom section header view
        self.tableView.register(R.nib.courseItemHeader(), forHeaderFooterViewReuseIdentifier: R.nib.courseItemHeader.name)

        self.addRefreshControl()

        var separatorInsetLeft: CGFloat = 16.0
        if #available(iOS 11.0, *) {
            self.tableView.separatorInsetReference = .fromAutomaticInsets
        } else {
            separatorInsetLeft += 11.0
        }

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: separatorInsetLeft, bottom: 0, right: 0)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)

        self.setupEmptyState()
        self.navigationItem.title = self.course.title

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.courseItemCell.identifier
        let request = CourseItemHelper.FetchRequest.orderedCourseItems(forCourse: course)
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.position") // must be the first sort descriptor
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.refresh()
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
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
        let item = self.dataSource.object(at: indexPath)
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

        let indexPath = IndexPath(row: 0, section: section)
        guard let section = self.dataSource.object(at: indexPath).section else {
            return nil
        }

        header.configure(for: section, inOfflineMode: self.inOfflineMode)
        header.delegate = self

        return header
    }

}

extension CourseItemListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: CourseItemCell, for object: CourseItem) {
        cell.delegate = self
        cell.configure(for: object)
    }

}

extension CourseItemListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseItemHelper.syncCourseItems(forCourse: self.course).asVoid()
    }

    func postRefresh() {
        let contentPreloadOption = UserDefaults.standard.contentPreloadSetting
        let preloadingWanted = contentPreloadOption == .always || (contentPreloadOption == .wifiOnly && ReachabilityHelper.connection == .wifi)
        self.isPreloading = preloadingWanted && !self.contentToBePreloaded.isEmpty

        guard preloadingWanted else { return }
        self.preloadCourseContent()
    }

}

extension CourseItemListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.course-content.title", comment: "title for empty course content list")
        return NSAttributedString(string: title)
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

extension CourseItemListViewController: CourseAreaViewController {

    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate) {
        self.course = course
    }

}
