//
//  CourseItemListViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import DZNEmptyDataSet
import ReachabilitySwift

class CourseItemListViewController: UITableViewController {
    typealias Resource = CourseItem

    var course: Course!

    var resultsController: NSFetchedResultsController<CourseItem>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseItem>!

    var contentToBePreloaded: [DetailedContent.Type] = [Video.self, RichText.self]
    var isPreloading = false
    var isOffline = ReachabilityHelper.reachabilityStatus == .notReachable {
        didSet {
            if oldValue != self.isOffline {
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

        var separatorInsetLeft: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            self.tableView.separatorInsetReference = .fromAutomaticInsets
        } else {
            separatorInsetLeft = separatorInsetLeft + 15.0
        }
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: separatorInsetLeft, bottom: 0, right: 0)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NotificationKeys.reachabilityChanged,
                                               object: nil)

        self.setupEmptyState()
        self.navigationItem.title = self.course.title

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        let request = CourseItemHelper.FetchRequest.orderedCourseItems(forCourse: course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.position")  // must be equal to the first sort descriptor
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "CourseItemCell")

        let configuration = CourseItemListViewConfiguration(tableViewController: self)
        let configurationWrapper = TableViewResultsControllerConfigurationWrapper(configuration)
        resultsControllerDelegateImplementation.configuration = configurationWrapper
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        self.refresh()

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
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
        let preloadingWanted = contentPreloadOption == .always || (contentPreloadOption == .wifiOnly && ReachabilityHelper.reachabilityStatus == .reachableViaWiFi)
        self.isPreloading = preloadingWanted && !self.contentToBePreloaded.isEmpty

        guard UserProfileHelper.isLoggedIn() else {
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
        TrackingHelper.createEvent(.visitedItem, resourceType: .item, resourceId: item.id, context: ["content_type": item.contentType])

        switch item.contentType {
        case "video"?:
            self.performSegue(withIdentifier: "ShowVideo", sender: item)
        case "rich_text"?:
            self.performSegue(withIdentifier: "ShowRichtext", sender: item)
        default:
            self.performSegue(withIdentifier: "ShowCourseItem", sender: item)
        }
    }

    @objc func reachabilityChanged() {
        self.isOffline = ReachabilityHelper.reachabilityStatus == .notReachable
    }

    func preloadCourseContent() {
        self.contentToBePreloaded.traverse { contentType in
            return contentType.preloadContentFor(course: self.course)
        }.onComplete { _ in
            self.isPreloading = false
            for case let cell as CourseItemCell in self.tableView.visibleCells {
                cell.removeLoadingState()
            }
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
            print("Sender is not a course item")
            super.prepare(for: segue, sender: sender)
            return
        }

        switch segue.identifier {
        case "ShowVideo"?:
            let videoViewController = segue.destination as! VideoViewController
            videoViewController.courseItem = courseItem
        case "ShowCourseItem"?:
            let webView = segue.destination as! CourseItemWebViewController
            webView.courseItem = courseItem
        case "ShowRichtext"?:
            let richtextViewController = segue.destination as! RichtextViewController
            richtextViewController.courseItem = courseItem
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension CourseItemListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.resultsController.object(at: indexPath)
        if item.proctored && (self.course.enrollment?.proctored ?? false) {
            self.showProctoringDialog(onComplete: {
                tableView.deselectRow(at: indexPath, animated: true)
            })
        } else {
            self.showItem(item)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}


class CourseItemListViewConfiguration : TableViewResultsControllerConfiguration {
    weak var tableViewController: CourseItemListViewController?

    init(tableViewController: CourseItemListViewController) {
        self.tableViewController = tableViewController
    }

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<CourseItem>, indexPath: IndexPath) {
        let cell = cell as! CourseItemCell
        let item = controller.object(at: indexPath)
        cell.delegate = self.tableViewController

        let configuration = CourseItemCellConfiguration(contentTypes: self.tableViewController?.contentToBePreloaded ?? [],
                                                        isPreloading: self.tableViewController?.isPreloading ?? false,
                                                        inOfflineMode: self.tableViewController?.isOffline ?? false)
        cell.configure(for: item, with: configuration)
    }

    func headerTitle(forController controller: NSFetchedResultsController<CourseItem>, forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        let item = controller.object(at: indexPath)
        return item.section?.title
    }

}


extension CourseItemListViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.course-content.title", comment: "title for empty course content list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.course-content.description",
                                            comment: "description for empty course content list")
        return NSAttributedString(string: description)
    }

}

extension CourseItemListViewController: VideoCourseItemCellDelegate {

    func videoCourseItemCell(_ cell: CourseItemCell, downloadStateDidChange newState: Video.DownloadState) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }

        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }


    func showAlertForDownloading(of video: Video, forCell cell: CourseItemCell) {
        let downloadActionTitle = NSLocalizedString("course-item.video-download-alert.start-download-action.title",
                                                    comment: "start download of video item")
        let downloadAction = UIAlertAction(title: downloadActionTitle, style: .default) { action in
            if video.singleStream?.hlsURL != nil {
                VideoPersistenceManager.shared.downloadStream(for: video)
            } else {
                DispatchQueue.main.async {
                    cell.singleReloadInProgress = true
                }
                VideoHelper.syncVideo(video).onComplete { result in
                    DispatchQueue.main.async {
                        cell.singleReloadInProgress = false
                    }
                    VideoPersistenceManager.shared.downloadStream(for: video)
                }
            }
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
        
        self.showAlert(withActions: [downloadAction, cancelAction], onView: cell.downloadButton)
    }

    func showAlertForCancellingDownload(of video: Video, forCell cell: CourseItemCell) {
        let abortActionTitle = NSLocalizedString("course-item.video-download-alert.stop-download-action.title",
                                                 comment: "stop download of video item")
        let abortAction = UIAlertAction(title: abortActionTitle, style: .default) { action in
            VideoPersistenceManager.shared.cancelDownload(for: video)
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
        
        self.showAlert(withActions: [abortAction, cancelAction], onView: cell.downloadButton)
    }

    func showAlertForDeletingDownload(of video: Video, forCell cell: CourseItemCell) {
        let deleteActionTitle = NSLocalizedString("course-item.video-download-alert.delete-item-action.title",
                                                  comment: "delete video item")
        let deleteAction = UIAlertAction(title: deleteActionTitle, style: .default) { action in
            VideoPersistenceManager.shared.deleteAsset(for: video)
        }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)
        
        self.showAlert(withActions: [deleteAction, cancelAction], onView: cell.downloadButton)
    }

    private func showAlert(withActions actions: [UIAlertAction], onView view: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = view.bounds.offsetBy(dx: -4, dy: 0)

        for action in actions {
            alert.addAction(action)
        }

        self.present(alert, animated: true)
    }

}
