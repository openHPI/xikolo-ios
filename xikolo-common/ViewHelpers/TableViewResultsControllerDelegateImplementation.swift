//
//  TableViewResultsControllerDelegateImplementation.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class TableViewResultsControllerDelegateImplementation : NSObject, NSFetchedResultsControllerDelegate {

    weak var tableView: UITableView!
    weak var resultsController: NSFetchedResultsController?
    var cellReuseIdentifier: String

    weak var delegate: TableViewResultsControllerDelegateImplementationDelegate?

    required init(_ tableView: UITableView, resultsController: NSFetchedResultsController?, cellReuseIdentifier: String) {
        self.tableView = tableView
        self.resultsController = resultsController
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    convenience init(_ tableView: UITableView, cellReuseIdentifier: String) {
        self.init(tableView, resultsController: nil, cellReuseIdentifier: cellReuseIdentifier)
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
                self.delegate?.configureTableCell(cell, indexPath: indexPath!)
            } else {
                // Undocumented by Apple:
                // Need to create rows that don't exist here to prevent assertion errors.
                tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

}

extension TableViewResultsControllerDelegateImplementation : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let resultsController = resultsController {
            if resultsController.sectionNameKeyPath == nil {
                return 1
            } else {
                return resultsController.sections?.count ?? 0
            }
        }
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController?.sections?[section].numberOfObjects ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        self.delegate?.configureTableCell(cell, indexPath: indexPath)
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsController?.sections?[section].name
    }

}

protocol TableViewResultsControllerDelegateImplementationDelegate : class {

    func configureTableCell(cell: UITableViewCell, indexPath: NSIndexPath)

}
