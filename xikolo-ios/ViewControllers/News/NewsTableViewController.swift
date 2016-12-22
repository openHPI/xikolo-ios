//
//  NewsTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import DZNEmptyDataSet

class NewsTableViewController : UITableViewController {

    var resultsController: NSFetchedResultsController!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!

    deinit {
        self.tableView?.emptyDataSetSource = nil
        self.tableView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NewsArticleHelper.getRequest()
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        resultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(tableView, resultsController: resultsController, cellReuseIdentifier: "NewsArticleCell")
        resultsControllerDelegateImplementation.delegate = self
        resultsController.delegate = resultsControllerDelegateImplementation
        tableView.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            // TODO: Error handling.
        }
        NewsArticleHelper.syncNewsArticles().onComplete { _ in
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let newsVC = segue.destinationViewController as! NewsArticleViewController
        let newsArticle = sender as! NewsArticle
        newsVC.newsArticle = newsArticle
    }

}

extension NewsTableViewController { // TableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsArticle = resultsController.objectAtIndexPath(indexPath) as! NewsArticle
        performSegueWithIdentifier("ShowNewsArticle", sender: newsArticle)
    }

}

extension NewsTableViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let cell = cell as! NewsArticleCell

        let article = resultsController.objectAtIndexPath(indexPath) as! NewsArticle
        cell.configure(article)
    }

}

extension NewsTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let title = NSLocalizedString("There are no news at the moment", comment: "")
        let attributedString = NSAttributedString(string: title)
        return attributedString
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if NetworkIndicator.counter > 0 {
            return nil // blank screen for loading
        }
        let description = NSLocalizedString("News can be published in courses or globally to announce new content or changes to the platform itself", comment: "")
        let attributedString = NSAttributedString(string: description)
        return attributedString
    }

}
