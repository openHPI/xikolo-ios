//
//  PlatformEventsTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 06.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import DZNEmptyDataSet

class PlatformEventsTableViewController: UITableViewController {

    var resultsController: NSFetchedResultsController<PlatformEvent>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<PlatformEvent>!

    var course: Course?

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // setup table view data
        let course = self.course.require(hint: "Platform event list need course for filtering")
        let request = PlatformEventHelper.FetchRequest.platformEvents(forCourse: course)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView,
                                                                                                   resultsController: [resultsController],
                                                                                                   cellReuseIdentifier: "PlatformEventCell")
        let configuration = TableViewResultsControllerConfigurationWrapper(PlatformEventsTableViewConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        self.updateAfterLoginStateChange()

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        self.tableView.reloadData()
        self.setupEmptyState()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PlatformEventsTableViewController.updateAfterLoginStateChange),
                                               name: NotificationKeys.loginStateChangedKey,
                                               object: nil)
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
    }

    @objc func updateAfterLoginStateChange() {
        self.refresh()
    }

    @objc func refresh() {
        self.tableView.reloadEmptyDataSet()

        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        if UserProfileHelper.isLoggedIn(), let course = self.course {
            PlatformEventHelper.syncPlatformEvents(forCourse: course).onComplete { _ in
                stopRefreshControl()
            }
        } else {
            stopRefreshControl()
        }
    }

}

struct PlatformEventsTableViewConfiguration : TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<PlatformEvent>, indexPath: IndexPath) {
        let cell = cell as! PlatformEventCell
        let event = controller.object(at: indexPath)
        cell.configure(event)
    }

}

extension PlatformEventsTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSLocalizedString("empty-view.platform-events.title",
                                      comment: "title for empty platform event list")
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description = NSLocalizedString("empty-view.platform-events.description",
                                            comment: "description for empty platform event list")
        return NSAttributedString(string: description)
    }

}
