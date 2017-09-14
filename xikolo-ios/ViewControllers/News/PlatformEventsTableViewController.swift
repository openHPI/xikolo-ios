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

    func updateAfterLoginStateChange() {
        self.tableView.reloadEmptyDataSet()
        if UserProfileHelper.isLoggedIn() {
            PlatformEventHelper.syncPlatformEvents()
        }

        // FIXME: This call dhould not be made here. However without this call the table view does not refresh after a logout.
        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
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
            title = NSLocalizedString("There has been no course activity yet", comment: "")
        } else {
            title = NSLocalizedString("Please log in to see course activity", comment: "")
        }
        return NSAttributedString(string: title)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let description: String
        if UserProfileHelper.isLoggedIn() {
            description = NSLocalizedString("Notifications about course material or discussions of enrolled courses will appear here", comment: "")
        } else {
            description = NSLocalizedString("Course activity is specific to your courses so we need to now what you're enrolled in", comment: "")
        }
        return NSAttributedString(string: description)
    }

}
