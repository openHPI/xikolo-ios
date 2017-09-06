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

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "PlatformEventCell")
        let configuration = TableViewResultsControllerConfigurationWrapper(PlatformEventsTableViewConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        PlatformEventHelper.syncPlatformEvents().onComplete { _ in
                self.tableView.reloadEmptyDataSet()
        }
        setupEmptyState()
    }

    func setupEmptyState() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadEmptyDataSet()
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
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let title: String
        if UserProfileHelper.isLoggedIn() {
            title = NSLocalizedString("empty-view.platform-events.no-activities.title",
                                      comment: "title for empty platform event list if logged in")
        } else {
            title = NSLocalizedString("empty-view.platform-events.not-logged-in.title",
                                      comment: "title for empty announcement list if not logged in")
        }
        let attributedString = NSAttributedString(string: title)
        return attributedString
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let description: String
        if UserProfileHelper.isLoggedIn() {
            description = NSLocalizedString("empty-view.platform-events.no-activities.description",
                                            comment: "description for empty platform event list if logged in")
        } else {
            description = NSLocalizedString("empty-view.platform-events.not-logged-in.description",
                                            comment: "description for empty announcement list if not logged in")
        }
        let attributedString = NSAttributedString(string: description)
        return attributedString
    }

}
