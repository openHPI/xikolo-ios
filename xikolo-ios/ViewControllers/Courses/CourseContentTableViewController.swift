//
//  CourseContentTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import DZNEmptyDataSet
import ReachabilitySwift

class CourseContentTableViewController: UITableViewController {
    typealias Resource = CourseItem

    var course: Course!

    var resultsController: NSFetchedResultsController<CourseItem>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseItem>!

    var contentToBePreloaded: [DetailedContent.Type] = [Video.self, RichText.self]
    var isPreloading = false

    var isOffline = false
    var reachability: Reachability?

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
        self.stopReachabilityNotifier()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupReachability(Brand.host)
        self.startReachabilityNotifier()
        self.setupEmptyState()
        self.navigationItem.title = self.course.title

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        let request = CourseItemHelper.getItemRequest(course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.sectionName")
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "CourseItemCell")

        let configuration = CourseContentTableViewConfiguration(tableViewController: self)
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

    func setupReachability(_ host: String?) {
        if let hostName = host {
            self.reachability = Reachability(hostname: hostName)
        } else {
            self.reachability = Reachability()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(CourseContentTableViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: self.reachability)
    }

    private func startReachabilityNotifier() {
        do {
            try self.reachability?.startNotifier()
        } catch {
            print("Failed to start reachability notificaition")
        }
    }

    private func stopReachabilityNotifier() {
        self.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.reachability = nil
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        let contentPreloadDeactivated = UserDefaults.standard.bool(forKey: UserDefaultsKeys.noContentPreloadKey)
        self.isPreloading = !contentPreloadDeactivated && !self.contentToBePreloaded.isEmpty

        // FIXME: Due to the incorrect handling of the NSManagedObjectContext spine sync logic, we have to refetch the course for the background context
        if UserProfileHelper.isLoggedIn(), let course = CourseHelper.getByID(self.course.id) {
            CourseSectionHelper.syncCourseSections(course).flatMap { sections in
                sections.map { section in
                    CourseItemHelper.syncCourseItems(section)
                }.sequence().onComplete { _ in
                    if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.noContentPreloadKey) {
                        self.preloadCourseContent()
                    }
                }
            }.onComplete { _ in
                stopRefreshControl()
            }
        } else {
            stopRefreshControl()
        }
    }

    func showItem(_ item: CourseItem) {
        TrackingHelper.sendEvent("VISITED_ITEM", resource: item)
        //save read state to server
        item.visited = true
        SpineHelper.save(CourseItemSpine.init(courseItem: item))
        
        switch item.content {
            case is Video:
                performSegue(withIdentifier: "ShowVideo", sender: item)
            case is LTIExercise, is Quiz, is PeerAssessment:
                performSegue(withIdentifier: "ShowQuiz", sender: item)
            case is RichText:
                performSegue(withIdentifier: "ShowRichtext", sender: item)
            default:
                // TODO: show error: unsupported type
                break
        }
    }

    @objc func reachabilityChanged(_ note: Notification) {
        guard let reachability = note.object as? Reachability else { return }

        let oldOfflinesState = self.isOffline
        self.isOffline = !reachability.isReachable

        if oldOfflinesState != self.isOffline {
            self.tableView.reloadData()
        }
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
        let courseItem = sender as? CourseItem
        switch segue.identifier! {
        case "ShowVideo":
            let videoView = segue.destination as! VideoViewController
            videoView.courseItem = try! CourseItemHelper.getByID(courseItem!.id)
            break
        case "ShowQuiz":
            let webView = segue.destination as! WebViewController
            if let courseID = courseItem!.section?.course?.id {
                let courseURL = Routes.COURSES_URL + courseID
                let quizpathURL = "/items/" + courseItem!.id
                let url = courseURL + quizpathURL
                webView.url = url
            }
            break
        case "ShowRichtext":
            let richtextView = segue.destination as! RichtextViewController
            richtextView.courseItem = try! CourseItemHelper.getByID(courseItem!.id)
            break
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension CourseContentTableViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = resultsController.object(at: indexPath)
        if item.proctored && (course.enrollment?.proctored ?? false) {
            showProctoringDialog(onComplete: {
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
        } else {
            showItem(item)
        }
    }

}


class CourseContentTableViewConfiguration : TableViewResultsControllerConfiguration {
    weak var tableViewController: CourseContentTableViewController?

    init(tableViewController: CourseContentTableViewController) {
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

}


extension CourseContentTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

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

extension CourseContentTableViewController: VideoCourseItemCellDelegate {

    func videoCourseItemCell(_ cell: CourseItemCell, downloadStateDidChange newState: Video.DownloadState) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }

        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }


    func showAlertForDownloading(of video: Video, forCell cell: CourseItemCell) {
        let downloadActionTitle = NSLocalizedString("course-item.video-download-alert.start-download-action.title",
                                                    comment: "start download of video item")
        let downloadAction = UIAlertAction(title: downloadActionTitle, style: .default) { action in
            if video.hlsURL != nil {
                VideoPersistenceManager.shared.downloadStream(for: video)
            } else if let backgroundVideo = VideoHelper.videoWith(id: video.id) {  // We need the video on a background context to sync via spine
                DispatchQueue.main.async {
                    cell.singleReloadInProgress = true
                }
                VideoHelper.sync(video: backgroundVideo).onComplete { result in
                    DispatchQueue.main.async {
                        cell.singleReloadInProgress = false
                    }
                    if let syncedVideo = result.value, syncedVideo.hlsURL != nil {
                        VideoPersistenceManager.shared.downloadStream(for: video)
                    }
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
        for action in actions {
            alert.addAction(action)
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds.offsetBy(dx: -4, dy: 0)
        }

        self.present(alert, animated: true)
    }

}
