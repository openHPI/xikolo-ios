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
    var resultsControllers: [NSFetchedResultsController<NSFetchRequestResult>]
    var cellReuseIdentifier: String

    weak var delegate: TableViewResultsControllerDelegateImplementationDelegate?

    required init(_ tableView: UITableView, resultsController: [NSFetchedResultsController<NSFetchRequestResult>], cellReuseIdentifier: String) {
        self.tableView = tableView
        self.resultsControllers = resultsController
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let convertedIndexSet = self.indexSet(for: controller, with: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(convertedIndexSet!, with: .fade)
        case .delete:
            tableView.deleteSections(convertedIndexSet!, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let convertedIndexPath = self.indexPath(for: controller, with: indexPath)
        let convertedNewIndexPath = self.indexPath(for: controller, with: newIndexPath)
        switch type {
        case .insert:
            tableView.insertRows(at: [convertedNewIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [convertedIndexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: convertedIndexPath!) {
                self.delegate?.configureTableCell(cell, for: controller, indexPath: indexPath!)
            } else {
                #if os(tvOS)
                // Undocumented by Apple:
                // Need to create rows that don't exist here to prevent assertion errors (tvOS only).
                tableView.insertRows(at: [convertedIndexPath!], with: .fade)
                #endif
            }
        case .move:
            tableView.deleteRows(at: [convertedIndexPath!], with: .fade)
            tableView.insertRows(at: [convertedNewIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

extension TableViewResultsControllerDelegateImplementation : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsControllers.reduce(0, { (partialCount, controller) -> Int in
            return (controller.sections?.count ?? 0) + partialCount
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionsToGo = section
        for controller in resultsControllers {
            let sectionCount = controller.sections?.count ?? 0
            if sectionsToGo >= sectionCount {
                sectionsToGo -= sectionCount
            } else {
                return controller.sections?[sectionsToGo].numberOfObjects ?? 0
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let (controller, newIndexPath) = controllerAndImplementationIndexPath(forVisual: indexPath)!
        self.delegate?.configureTableCell(cell, for: controller, indexPath: newIndexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (controller, newSection) = controllerAndImplementationSection(forSection: section)!
            return controller.sections?[newSection].name
    }

}

extension TableViewResultsControllerDelegateImplementation { // Conversion of indices between data and views
    // correct "visual" indexPath for data controller and its indexPath (data->visual)
    func indexPath(for controller: NSFetchedResultsController<NSFetchRequestResult>, with indexPath: IndexPath?) -> IndexPath? {
        guard var newIndexPath = indexPath else {
            return nil
        }
        for contr in resultsControllers {
            if contr == controller {
                return newIndexPath
            } else {
                newIndexPath.section += contr.sections?.count ?? 0
            }
        }
        return nil
    }

    // correct "visual" indexSet for data controller and its indexSet (data->visual)
    func indexSet(for controller: NSFetchedResultsController<NSFetchRequestResult>, with sectionIndex: Int?) -> IndexSet? {
        guard let oldSectionIndex = sectionIndex else { return nil }
        var convertedIndexSet = IndexSet()
        var passedSections = 0
        for contr in resultsControllers {
            if contr == controller {
                passedSections += oldSectionIndex
                convertedIndexSet.insert(passedSections)
                break
            } else {
                passedSections += contr.sections?.count ?? 0
            }
        }
        return convertedIndexSet
    }

    // find data controller and its sectionIndex for a given "visual" sectionIndex (visual->data)
    func controllerAndImplementationSection(forSection section: Int) -> (NSFetchedResultsController<NSFetchRequestResult>, Int)? {
        var passedSections = 0
        for contr in resultsControllers {
            if passedSections + (contr.sections?.count ?? 0) > section {
                let newSection = section - passedSections
                return (contr, newSection)
            } else {
                passedSections += (contr.sections?.count ?? 0)
            }
        }
        return nil
    }

    // find data controller and its indexPath for a given "visual" indexPath (visual->data)
    func controllerAndImplementationIndexPath(forVisual indexPath: IndexPath) -> (NSFetchedResultsController<NSFetchRequestResult>, IndexPath)? {
        var passedSections = 0
        for contr in resultsControllers {
            if passedSections + (contr.sections?.count ?? 0) > indexPath.section {
                let newIndexPath = IndexPath(item: indexPath.item, section: indexPath.section - passedSections)
                return (contr, newIndexPath)
            } else {
                passedSections += (contr.sections?.count ?? 0)
            }
        }
        return nil
    }
    
}

protocol TableViewResultsControllerDelegateImplementationDelegate : class {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<NSFetchRequestResult>, indexPath: IndexPath)

}
