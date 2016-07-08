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

    @IBOutlet var newsTableView: UITableView!

    var resultsController: NSFetchedResultsController!

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NewsArticleHelper.getRequest()
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        resultsController.delegate = self
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return resultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = resultsController.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]

        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil //resultsController.sections![section].name
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("newsTableViewCell", forIndexPath: indexPath) as! NewsTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func configureCell(cell: NewsTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = resultsController.objectAtIndexPath(indexPath) as! NewsArticle
        cell.newsArticle = item
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let newsView = segue.destinationViewController as! NewsArticleViewController
        let newsArticle = sender as! NewsArticle // Could not cast value of type 'xikolo_ios.NewsArticle' (0x7a105378) to 'xikolo_ios.NewsTableViewCell' (0x9a814). 
        // Could not cast value of type 'xikolo_ios.NewsTableViewCell' (0xed814) to 'xikolo_ios.NewsArticle' (0xed284).
        newsView.newsArticle = newsArticle
    }
}

extension NewsTableViewController : NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        newsTableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            newsTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            newsTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            newsTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            newsTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            // No need to update a cell that has not been loaded.
            if let cell = newsTableView.cellForRowAtIndexPath(indexPath!) as? NewsTableViewCell {
                configureCell(cell, atIndexPath: indexPath!)
            }
        case .Move:
            newsTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            newsTableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        newsTableView.endUpdates()
    }

}
