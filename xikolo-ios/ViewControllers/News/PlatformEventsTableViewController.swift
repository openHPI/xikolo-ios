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
        let request = PlatformEventHelper.getRequest()
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

        // FIXME: This call should not be made here. However without this call the table view does not refresh after a logout.
        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
    }

    @objc func refresh() {
        self.tableView.reloadEmptyDataSet()
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        if UserProfileHelper.isLoggedIn() {
            PlatformEventHelper.syncPlatformEvents().onComplete { _ in
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
        let title: String
        if UserProfileHelper.isLoggedIn() {
            title = NSLocalizedString("empty-view.platform-events.no-activities.title",
                                      comment: "title for empty platform event list if logged in")
        } else {
            title = NSLocalizedString("empty-view.platform-events.not-logged-in.title",
                                      comment: "title for empty announcement list if not logged in")
        }
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description: String
        if UserProfileHelper.isLoggedIn() {
            description = NSLocalizedString("empty-view.platform-events.no-activities.description",
                                            comment: "description for empty platform event list if logged in")
        } else {
            description = NSLocalizedString("empty-view.platform-events.not-logged-in.description",
                                            comment: "description for empty announcement list if not logged in")
        }
        return NSAttributedString(string: description)
    }

}
