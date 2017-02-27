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
    weak var resultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var cellReuseIdentifier: String

    weak var delegate: TableViewResultsControllerDelegateImplementationDelegate?

    required init(_ tableView: UITableView, resultsController: NSFetchedResultsController<NSFetchRequestResult>?, cellReuseIdentifier: String) {
        self.tableView = tableView
        self.resultsController = resultsController
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    convenience init(_ tableView: UITableView, cellReuseIdentifier: String) {
        self.init(tableView, resultsController: nil, cellReuseIdentifier: cellReuseIdentifier)
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) {
                self.delegate?.configureTableCell(cell, indexPath: indexPath!)
            } else {
                #if os(tvOS)
                // Undocumented by Apple:
                // Need to create rows that don't exist here to prevent assertion errors (tvOS only).
                tableView.insertRows(at: [indexPath!], with: .fade)
                #endif
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

extension TableViewResultsControllerDelegateImplementation : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if let resultsController = resultsController {
            if resultsController.sectionNameKeyPath == nil {
                return 1
            } else {
                return resultsController.sections?.count ?? 0
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController?.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        self.delegate?.configureTableCell(cell, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsController?.sections?[section].name
    }

}

protocol TableViewResultsControllerDelegateImplementationDelegate : class {

    func configureTableCell(_ cell: UITableViewCell, indexPath: IndexPath)

}
