//
//  NewsTableViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class NewsTableViewController: UITableViewController {

    var resultsController: NSFetchedResultsController!
    var resultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!

    // MARK: - ViewController Lifecycle

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
        NewsArticleHelper.syncNewsArticles()
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsArticle = resultsController!.objectAtIndexPath(indexPath) as! NewsArticle
        performSegueWithIdentifier("ShowNewsArticle", sender: newsArticle)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let newsView = segue.destinationViewController as! NewsArticleViewController
        let newsArticle = sender as! NewsArticle // Could not cast value of type 'xikolo_ios.NewsArticle' (0x7a105378) to 'xikolo_ios.NewsTableViewCell' (0x9a814). 
        // Could not cast value of type 'xikolo_ios.NewsTableViewCell' (0xed814) to 'xikolo_ios.NewsArticle' (0xed284).
        newsView.newsArticle = newsArticle
    }
}

extension NewsTableViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let cell = cell as! NewsArticleCell

        let article = resultsController.objectAtIndexPath(indexPath) as! NewsArticle
        cell.configure(article)
    }

}
