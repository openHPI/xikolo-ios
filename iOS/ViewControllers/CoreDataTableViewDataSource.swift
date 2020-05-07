//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

protocol CoreDataTableViewDataSourceDelegate: AnyObject {

    associatedtype Object: NSFetchRequestResult
    associatedtype Cell: UITableViewCell

    func configure(_ cell: Cell, for object: Object)
    func titleForDefaultHeader(forSection section: Int) -> String?
    func titleForDefaultFooter(forSection section: Int) -> String?
    func canEditRow(at indexPath: IndexPath) -> Bool
    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)

}

extension CoreDataTableViewDataSourceDelegate {

    func titleForDefaultHeader(forSection section: Int) -> String? {
        return nil
    }

    func titleForDefaultFooter(forSection section: Int) -> String? {
        return nil
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return false
    }

    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }

}

class CoreDataTableViewDataSource<Delegate: CoreDataTableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    typealias Object = Delegate.Object
    typealias Cell = Delegate.Cell

    private weak var tableView: UITableView?
    private let fetchedResultsController: NSFetchedResultsController<Object>
    private let cellReuseIdentifier: String
    private weak var delegate: Delegate?

    private var contentChangeOperations: [BlockOperation] = []

    required init(_ tableView: UITableView,
                  fetchedResultsController: NSFetchedResultsController<Object>,
                  cellReuseIdentifier: String,
                  delegate: Delegate) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
        self.cellReuseIdentifier = cellReuseIdentifier
        self.delegate = delegate
        super.init()

        do {
            self.fetchedResultsController.delegate = self
            try self.fetchedResultsController.performFetch()
        } catch {
            ErrorManager.shared.report(error)
            logger.error("Error fetching items", error: error)
        }

        self.tableView?.dataSource = self
        self.tableView?.reloadData()
    }

    var sectionInfos: [NSFetchedResultsSectionInfo]? {
        return self.fetchedResultsController.sections
    }

    func object(at indexPath: IndexPath) -> Object {
        return self.fetchedResultsController.object(at: indexPath)
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard self.tableView?.window != nil else { return }
        if #available(iOS 11, *) {} else {
            self.tableView?.beginUpdates()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let sectionIndex = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            if #available(iOS 11, *) {
                self.contentChangeOperations.append(BlockOperation(block: {
                    self.tableView?.insertSections(sectionIndex, with: .fade)
                }))
            } else {
                self.tableView?.insertSections(sectionIndex, with: .fade)
            }
        case .delete:
            if #available(iOS 11, *) {
                self.contentChangeOperations.append(BlockOperation(block: {
                    self.tableView?.deleteSections(sectionIndex, with: .fade)
                }))
            } else {
                self.tableView?.deleteSections(sectionIndex, with: .fade)
            }
        case .move, .update:
            break
        @unknown default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let newIndexPath = newIndexPath.require(hint: "newIndexPath is required for table view cell insert")
            if #available(iOS 11, *) {
                self.contentChangeOperations.append(BlockOperation(block: {
                    self.tableView?.insertRows(at: [newIndexPath], with: .fade)
                }))
            } else {
                self.tableView?.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            let indexPath = indexPath.require(hint: "indexPath is required for table view cell delete")
            if #available(iOS 11, *) {
                self.contentChangeOperations.append(BlockOperation(block: {
                    self.tableView?.deleteRows(at: [indexPath], with: .fade)
                }))
            } else {
                self.tableView?.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            let indexPath = indexPath.require(hint: "indexPath is required for table view cell update")
            if #available(iOS 11, *) {
                self.contentChangeOperations.append(BlockOperation(block: {
                    self.tableView?.reloadRows(at: [indexPath], with: .fade)
                }))
            } else {
                self.tableView?.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            let indexPath = indexPath.require(hint: "indexPath is required for table view cell move")
            let newIndexPath = newIndexPath.require(hint: "newIndexPath is required for table view cell move")
            if #available(iOS 11, *) {
                self.contentChangeOperations.append(BlockOperation(block: {
                    self.tableView?.deleteRows(at: [indexPath], with: .fade)
                    self.tableView?.insertRows(at: [newIndexPath], with: .fade)
                }))
            } else {
                self.tableView?.deleteRows(at: [indexPath], with: .fade)
                self.tableView?.insertRows(at: [newIndexPath], with: .fade)
            } // swiftlint:disable:this closing_brace_whitespace
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if #available(iOS 11, *) {
            self.tableView?.performBatchUpdates({
                for operation in self.contentChangeOperations {
                    operation.start()
                }
            }, completion: { _ in
                self.contentChangeOperations.removeAll(keepingCapacity: false)
            })
        } else {
            self.tableView?.endUpdates()
        }
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let someCell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath) as? Cell
        let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(Cell.self)")
        let object = self.fetchedResultsController.object(at: indexPath)
        self.delegate?.configure(cell, for: object)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.delegate?.titleForDefaultHeader(forSection: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.delegate?.titleForDefaultFooter(forSection: section)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.delegate?.canEditRow(at: indexPath) ?? false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.delegate?.commit(editingStyle: editingStyle, forRowAt: indexPath)
    }

}
