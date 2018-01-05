//
//  CollectionViewResultsControllerDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

fileprivate let errorMessageIndexSetConversion = "Convertion of IndexSet for multiple FetchedResultsControllers failed"
fileprivate let errorMessageIndexPathConversion = "Convertion of IndexPath for multiple FetchedResultsControllers failed"
fileprivate let errorMessageNewIndexPathConversion = "Convertion of NewIndexPath for multiple FetchedResultsControllers failed"

class CollectionViewResultsControllerDelegateImplementation<T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {

    weak var collectionView: UICollectionView?
    var resultsControllers: [NSFetchedResultsController<T>] = [] // 2Think: Do we create a memory loop here?
    var cellReuseIdentifier: String
    var headerReuseIdentifier: String?

    var configuration: CollectionViewResultsControllerConfigurationWrapper<T>?
    private var contentChangeOperations: [BlockOperation] = []

    required init(_ collectionView: UICollectionView?, resultsControllers: [NSFetchedResultsController<T>], cellReuseIdentifier: String) {
        self.collectionView = collectionView
        self.resultsControllers = resultsControllers
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let convertedIndexSet = self.indexSet(for: controller, with: IndexSet(integer: sectionIndex)).require(hint: errorMessageIndexSetConversion)
        switch type {
        case .insert:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.insertSections(convertedIndexSet)
            }))
        case .delete:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.deleteSections(convertedIndexSet)
            }))
        case .move, .update:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let convertedIndexPath = self.indexPath(for: controller, with: indexPath)
        let convertedNewIndexPath = self.indexPath(for: controller, with: newIndexPath)
        switch type {
        case .insert:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [convertedNewIndexPath.require(hint: errorMessageNewIndexPathConversion)])
            }))
        case .delete:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.deleteItems(at: [convertedIndexPath.require(hint: errorMessageIndexPathConversion)])
            }))
        case .update:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.reloadItems(at: [convertedIndexPath.require(hint: errorMessageIndexPathConversion)])
            }))
        case .move:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.deleteItems(at: [convertedIndexPath.require(hint: errorMessageIndexPathConversion)])
                self.collectionView?.insertItems(at: [convertedNewIndexPath.require(hint: errorMessageNewIndexPathConversion)])
            }))
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView?.performBatchUpdates({
            for operation in self.contentChangeOperations {
                operation.start()
            }
        }, completion: { _ in
            self.contentChangeOperations.removeAll(keepingCapacity: false)
        })
    }

    deinit {
        for operation in self.contentChangeOperations {
            operation.cancel()
        }
        self.contentChangeOperations.removeAll(keepingCapacity: false)
        self.configuration = nil
        self.resultsControllers.removeAll(keepingCapacity: false)
        self.collectionView = nil
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.resultsControllers.map { $0.sections?.count ?? 0 }.reduce(0, +)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        let (controller, newIndexPath) = self.controllerAndImplementationIndexPath(forVisual: indexPath)! // TODO nil-handling or logging
        self.configuration?.configureCollectionCell(cell, for: controller, indexPath: newIndexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier!, for: indexPath)
            let (controller, newIndexPath) = controllerAndImplementationIndexPath(forVisual: indexPath)!
            if let section = controller.sections?[newIndexPath.section] {
                self.configuration?.configureCollectionHeaderView(view, section: section)
            }
            return view
        } else {
            return UICollectionReusableView()
        }
    }

}

extension CollectionViewResultsControllerDelegateImplementation { // Conversion of indices between data and views
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
    func indexSet(for controller: NSFetchedResultsController<NSFetchRequestResult>, with indexSet: IndexSet?) -> IndexSet? {
        guard let newIndexSet = indexSet else {
            return nil
        }
        var convertedIndexSet = IndexSet()
        var passedSections = 0
        for contr in resultsControllers {
            if contr == controller {
                for i in newIndexSet {
                    convertedIndexSet.insert(i + passedSections)
                }
                break
            } else {
                passedSections += contr.sections?.count ?? 0
            }
        }
        return convertedIndexSet
    }

    // find data controller and its indexPath for a given "visual" indexPath (visual->data)
    func controllerAndImplementationIndexPath(forVisual indexPath: IndexPath) -> (NSFetchedResultsController<T>, IndexPath)? {
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

protocol CollectionViewResultsControllerConfiguration {
    associatedtype Content : NSManagedObject

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<Content>, indexPath: IndexPath)

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo)

}

extension CollectionViewResultsControllerConfiguration {

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {}

}

// This is a wrapper for type erasure allowing the generic CollectionViewResultsControllerDelegateImplementation to be
// configured with a concrete type (via a configuration struct).
class CollectionViewResultsControllerConfigurationWrapper<T: NSManagedObject>: CollectionViewResultsControllerConfiguration {

    private let configureCollectionCell: (UICollectionViewCell, NSFetchedResultsController<T>, IndexPath) -> Void
    private let configureCollectionHeaderView: (UICollectionReusableView, NSFetchedResultsSectionInfo) -> Void

    required init<U: CollectionViewResultsControllerConfiguration>(_ configuration: U) where U.Content == T {
        self.configureCollectionCell = configuration.configureCollectionCell
        self.configureCollectionHeaderView = configuration.configureCollectionHeaderView
    }

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<T>, indexPath: IndexPath) {
        self.configureCollectionCell(cell, controller, indexPath)
    }

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {
        self.configureCollectionHeaderView(view, section)
    }

}
