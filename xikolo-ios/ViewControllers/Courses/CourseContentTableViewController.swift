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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability("google.com")//use brand host here
        startNotifier()
        self.setupEmptyState()

        self.navigationItem.title = self.course.title

        let contentPreloadDeactivated = UserDefaults.standard.bool(forKey: UserDefaultsKeys.noContentPreloadKey)
        self.isPreloading = !contentPreloadDeactivated && !self.contentToBePreloaded.isEmpty

        let request = CourseItemHelper.getItemRequest(course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.sectionName")

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "CourseItemCell")

        let configuration = CourseContentTableViewConfiguration(tableViewController: self)
        let configurationWrapper = TableViewResultsControllerConfigurationWrapper(configuration)
        resultsControllerDelegateImplementation.configuration = configurationWrapper
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
            NetworkIndicator.start()
            CourseSectionHelper.syncCourseSections(course).flatMap { sections in
                sections.map { section in
                    CourseItemHelper.syncCourseItems(section)
                    }.sequence().onComplete { _ in
                        self.tableView.reloadEmptyDataSet()
                        if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.noContentPreloadKey) {
                            self.preloadCourseContent()
                        }
                }
                }.onComplete { _ in
                    NetworkIndicator.end()
            }
        } catch {
            self.isOffline = true
            // TODO: Error handling.
        }
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }
    func setupReachability(_ hostName: String?) {
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability

        NotificationCenter.default.addObserver(self, selector: #selector(CourseContentTableViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)

    }

    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }

    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
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

    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        let oldOfflinesState = self.isOffline
        if reachability.isReachable {
            self.isOffline = false
        } else {
            self.isOffline = true
        }
        if oldOfflinesState !== self.isOffline {
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
        let title = NSLocalizedString("This item needs to be proctored", comment: "Shown in proctoring dialog")
        let message = NSLocalizedString("In order to receive your booked qualified certificate you have to complete this assignment on a computer with a webcam.", comment: "Shown in proctoring dialog")
        let confirm = NSLocalizedString("Ok", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: confirm, style: .default, handler: nil))

        present(alert, animated: true, completion: completionBlock )
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
        cell.configure(item,
                       forContentTypes: self.tableViewController?.contentToBePreloaded ?? [],
                       forPreloading: self.tableViewController?.isPreloading ?? false)
        // todo: helper in item isAvailablefflie
        if self.tableViewController!.isOffline && !(item.content?.isAvailableOffline())! {
            cell.titleView?.alpha = 0.5
            cell.downloadButton?.alpha = 0.5
            cell.isUserInteractionEnabled = false
        } else {
            cell.titleView?.alpha = 1
            cell.downloadButton?.alpha = 1
            cell.isUserInteractionEnabled = true

        }

    }

}


extension CourseContentTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let title = NSLocalizedString("Error loading course items", comment: "")
        let attributedString = NSAttributedString(string: title)
        return attributedString
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let description = NSLocalizedString("Please check you internet connection", comment: "")
        let attributedString = NSAttributedString(string: description)
        return attributedString
    }

}

extension CourseContentTableViewController: VideoCourseItemCellDelegate {

    func showAlertForDownloading(of video: Video, forCell cell: CourseItemCell) {
        let downloadAction = UIAlertAction(title: "Download video", style: .default) { action in
            DispatchQueue.main.async {
                cell.downloadButton.state = .pending
                DispatchQueue.global(qos: .background).async {
                    if video.hlsURL != nil {
                        VideoPersistenceManager.shared.downloadStream(for: video)
                    } else if let backgroundVideo = VideoHelper.videoWith(id: video.id) {  // We need the video on a background context
                        VideoHelper.sync(video: backgroundVideo).onComplete { result in
                            if let syncedVideo = result.value, syncedVideo.hlsURL != nil {
                                VideoPersistenceManager.shared.downloadStream(for: video)
                            } else {
                                DispatchQueue.main.async {
                                    cell.downloadButton.state = .startDownload
                                }
                            }
                        }
                    }                }
            }


        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        self.showAlert(withActions: [downloadAction, cancelAction], onView: cell.downloadButton)
    }

    func showAlertForCancellingDownload(of video: Video, forCell cell: CourseItemCell) {
        let abortAction = UIAlertAction(title: "Abort Download", style: .default) { action in
            DispatchQueue.global(qos: .background).async {
                VideoPersistenceManager.shared.cancelDownload(forVideo: video)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        self.showAlert(withActions: [abortAction, cancelAction], onView: cell.downloadButton)
    }

    func showAlertForDeletingDownload(of video: Video, forCell cell: CourseItemCell) {
        let deleteAction = UIAlertAction(title: "Delete video", style: .default) { action in
            DispatchQueue.global(qos: .background).async {
                VideoPersistenceManager.shared.deleteAsset(forVideo: video)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
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

        self.present(alert, animated: true, completion: nil)
    }

}
