//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Common
import UIKit

protocol CoreDataTableViewDataSourceDelegate: AnyObject {

    associatedtype Object: NSFetchRequestResult
    associatedtype Cell: UITableViewCell

    func configure(_ cell: Cell, for object: Object)
    func titleForDefaultHeader(forController controller: NSFetchedResultsController<Object>, forSection section: Int) -> String?

}

extension CoreDataTableViewDataSourceDelegate {

    func titleForDefaultHeader(forController controller: NSFetchedResultsController<Object>, forSection section: Int) -> String? {
        return nil
    }

}

class CoreDataTableViewDataSource<Delegate: CoreDataTableViewDataSourceDelegate> : NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell

    private let errorMessageIndexSetConversion = "Convertion of IndexSet for multiple FetchedResultsControllers failed"
    private let errorMessageIndexPathConversion = "Convertion of IndexPath for multiple FetchedResultsControllers failed"
    private let errorMessageNewIndexPathConversion = "Convertion of NewIndexPath for multiple FetchedResultsControllers failed"

    private weak var tableView: UITableView?
    private let fetchedResultsControllers: [NSFetchedResultsController<Object>]
    private let cellReuseIdentifier: String
    private weak var delegte: Delegate?

    required init(_ tableView: UITableView,
                  fetchedResultsControllers: [NSFetchedResultsController<Object>],
                  cellReuseIdentifier: String,
                  delegate: Delegate) {
        self.tableView = tableView
        self.fetchedResultsControllers = fetchedResultsControllers
        self.cellReuseIdentifier = cellReuseIdentifier
        self.delegte = delegate
        super.init()

        do {
            for fetchedResultsController in self.fetchedResultsControllers {
                fetchedResultsController.delegate = self
                try fetchedResultsController.performFetch()
            }
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }

        self.tableView?.dataSource = self
        self.tableView?.reloadData()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let convertedIndexSet = self.indexSet(for: controller, with: sectionIndex).require(hint: self.errorMessageIndexSetConversion)
        switch type {
        case .insert:
            self.tableView?.insertSections(convertedIndexSet, with: .fade)
        case .delete:
            self.tableView?.deleteSections(convertedIndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        let convertedIndexPath = self.indexPath(for: controller, with: indexPath)
        let convertedNewIndexPath = self.indexPath(for: controller, with: newIndexPath)
        switch type {
        case .insert:
            self.tableView?.insertRows(at: [convertedNewIndexPath.require(hint: errorMessageNewIndexPathConversion)], with: .fade)
        case .delete:
            self.tableView?.deleteRows(at: [convertedIndexPath.require(hint: self.errorMessageIndexPathConversion)], with: .fade)
        case .update:
            self.tableView?.reloadRows(at: [convertedIndexPath.require(hint: self.errorMessageIndexPathConversion)], with: .fade)
        case .move:
            self.tableView?.deleteRows(at: [convertedIndexPath.require(hint: self.errorMessageIndexPathConversion)], with: .fade)
            self.tableView?.insertRows(at: [convertedNewIndexPath.require(hint: self.errorMessageNewIndexPathConversion)], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.endUpdates()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsControllers.reduce(0) { partialCount, controller -> Int in
            return (controller.sections?.count ?? 0) + partialCount
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionsToGo = section
        for controller in self.fetchedResultsControllers {
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
        let someCell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath) as? Cell
        let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(Cell.self)")
        let (controller, newIndexPath) = self.controllerAndImplementationIndexPath(forVisual: indexPath)!
        let object = controller.object(at: newIndexPath)
        self.delegte?.configure(cell, for: object)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (controller, newSection) = self.controllerAndImplementationSection(forSection: section)!
        guard let headerTitle = self.delegte?.titleForDefaultHeader(forController: controller, forSection: newSection) else {
            return nil
        }

        return headerTitle
    }

}

extension CoreDataTableViewDataSource { // Conversion of indices between data and views
    // correct "visual" indexPath for data controller and its indexPath (data->visual)
    func indexPath(for controller: NSFetchedResultsController<NSFetchRequestResult>, with indexPath: IndexPath?) -> IndexPath? {
        guard var newIndexPath = indexPath else {
            return nil
        }

        for contr in self.fetchedResultsControllers {
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
        for contr in self.fetchedResultsControllers {
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
    func controllerAndImplementationSection(forSection section: Int) -> (NSFetchedResultsController<Object>, Int)? {
        var passedSections = 0
        for contr in self.fetchedResultsControllers {
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
    func controllerAndImplementationIndexPath(forVisual indexPath: IndexPath) -> (NSFetchedResultsController<Object>, IndexPath)? {
        var passedSections = 0
        for contr in self.fetchedResultsControllers {
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
