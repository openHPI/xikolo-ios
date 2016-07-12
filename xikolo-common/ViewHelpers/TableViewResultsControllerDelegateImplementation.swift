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
    weak var delegate: TableViewResultsControllerDelegateImplementationDelegate?

    required init(_ tableView: UITableView) {
        self.tableView = tableView
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
                self.delegate?.configureTableCell(self, cell: cell, indexPath: indexPath!)
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

protocol TableViewResultsControllerDelegateImplementationDelegate : class {

    func configureTableCell(delegateImplementation: TableViewResultsControllerDelegateImplementation, cell: UITableViewCell, indexPath: NSIndexPath)

}
