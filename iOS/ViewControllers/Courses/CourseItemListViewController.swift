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

    private static let contentToBePreloaded: [PreloadableCourseItemContent.Type] = [Video.self, RichText.self]

    private var course: Course!
    private var dataSource: CoreDataTableViewDataSource<CourseItemListViewController>!

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
        self.tableView.register(UINib(resource: R.nib.courseItemHeader), forHeaderFooterViewReuseIdentifier: R.nib.courseItemHeader.name)

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

    @objc func reachabilityChanged() {
        self.inOfflineMode = ReachabilityHelper.connection == .none
    }

    func preloadCourseContent() {
        CourseItemListViewController.contentToBePreloaded.traverse { contentType in
            return contentType.preloadContent(forCourse: self.course)
        }.onComplete { _ in
            self.isPreloading = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? CourseItemCell else { return }
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }

        if let typeInfo = R.segue.courseItemListViewController.showCourseItem(segue: segue) {
            typeInfo.destination.currentItem = self.dataSource.object(at: indexPath)
        }
    }

}

extension CourseItemListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

    private var preloadingWanted: Bool {
        let contentPreloadOption = UserDefaults.standard.contentPreloadSetting
        return contentPreloadOption == .always || (contentPreloadOption == .wifiOnly && ReachabilityHelper.connection == .wifi)
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        self.isPreloading = self.preloadingWanted && !CourseItemListViewController.contentToBePreloaded.isEmpty
        return CourseItemHelper.syncCourseItems(forCourse: self.course).asVoid()
    }

    func didRefresh() {
        guard self.preloadingWanted else { return }
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

extension CourseItemListViewController: CourseItemCellDelegate {

    func isPreloading(for contentType: String?) -> Bool {
        return self.isPreloading && CourseItemListViewController.contentToBePreloaded.contains { $0.contentType == contentType }
    }

}

extension CourseItemListViewController: UserActionsDelegate {

    func showAlert(with actions: [UIAlertAction], title: String?, message: String?, on anchor: UIView) {
        guard !actions.isEmpty else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = anchor
        alert.popoverPresentationController?.sourceRect = anchor.bounds.insetBy(dx: -4, dy: -4)
        alert.popoverPresentationController?.permittedArrowDirections = [.left, .right]

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
