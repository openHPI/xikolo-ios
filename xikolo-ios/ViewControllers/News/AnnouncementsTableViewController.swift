//
//  AnnouncementTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import DZNEmptyDataSet

class AnnouncementsTableViewController : UITableViewController {

    var resultsController: NSFetchedResultsController<Announcement>!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<Announcement>!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = AnnouncementHelper.getRequest()
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: [resultsController], cellReuseIdentifier: "AnnouncementCell")
        let configuration = TableViewResultsControllerConfigurationWrapper(AnnouncementsTableViewConfiguration())
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        AnnouncementHelper.syncAnnouncements().onComplete { _ in
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newsVC = segue.destination as! AnnouncementViewController
        let announcement = sender as! Announcement
        newsVC.announcement = announcement
    }

}

extension AnnouncementsTableViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let announcement = resultsController.object(at: indexPath)
        performSegue(withIdentifier: "ShowAnnouncement", sender: announcement)
    }

}

struct AnnouncementsTableViewConfiguration : TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<Announcement>, indexPath: IndexPath) {
        let cell = cell as! AnnouncementCell
        let announcement = controller.object(at: indexPath)
        cell.configure(announcement)
    }

}

extension AnnouncementsTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let title = NSLocalizedString("There are no news at the moment", comment: "")
        let attributedString = NSAttributedString(string: title)
        return attributedString
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let description = NSLocalizedString("News can be published in courses or globally to announce new content or changes to the platform itself", comment: "")
        let attributedString = NSAttributedString(string: description)
        return attributedString
    }

}
