//
//  CollectionViewResultsControllerDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CollectionViewResultsControllerDelegateImplementation<T: BaseModel> : NSObject, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {

    weak var collectionView: UICollectionView?
    var resultsControllers: [NSFetchedResultsController<T>] // 2Think: Do we create a memory loop here?
    var cellReuseIdentifier: String
    var headerReuseIdentifier: String?

    var configuration: CollectionViewResultsControllerConfigurationWrapper<T>?
    fileprivate var contentChangeOperations: [ContentChangeOperation] = []

    required init(_ collectionView: UICollectionView, resultsControllers: [NSFetchedResultsController<T>], cellReuseIdentifier: String) {
        self.collectionView = collectionView
        self.resultsControllers = resultsControllers
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        contentChangeOperations.removeAll()
    }

    // TODO: Still need to do this one?
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexSet: IndexSet(integer: sectionIndex)))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexPath: indexPath, newIndexPath: newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            let collectionView = self.collectionView!
            for change in self.contentChangeOperations {
                switch change.context {
                case .section:
                    let convertedIndexSet = self.indexSet(for: controller, with: change.indexSet)
                    switch change.type {
                    case .insert:
                        collectionView.insertSections(convertedIndexSet!)
                    case .delete:
                        collectionView.deleteSections(convertedIndexSet!)
                    case .move:
                        break
                    case .update:
                        break
                    }
                case .object:
                    let convertedIndexPath = self.indexPath(for: controller, with: change.indexPath)
                    let convertedNewIndexPath = self.indexPath(for: controller, with: change.newIndexPath)
                    switch change.type {
                    case .insert:
                        collectionView.insertItems(at: [convertedNewIndexPath!]) // TODO: nilhandling
                    case .delete:
                        collectionView.deleteItems(at: [convertedIndexPath!])
                    case .update:
                        collectionView.reloadItems(at: [convertedIndexPath!])
                    case .move:
                        collectionView.deleteItems(at: [convertedIndexPath!])
                        collectionView.insertItems(at: [convertedNewIndexPath!])
                    }
                }
            }
        }, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return resultsControllers.reduce(0, { (partialCount, controller) -> Int in
            return (controller.sections?.count ?? 0) + partialCount
        })
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
            fatalError("Unsupported supplementary view kind.")
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
                newIndexSet.forEach { (i) in
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
    associatedtype Content : BaseModel

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<Content>, indexPath: IndexPath)

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo)

}

extension CollectionViewResultsControllerConfiguration {

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {}

}

// This is a wrapper for type erasure allowing the generic CollectionViewResultsControllerDelegateImplementation to be
// configured with a concrete type (via a configuration struct).
class CollectionViewResultsControllerConfigurationWrapper<T: BaseModel>: CollectionViewResultsControllerConfiguration {

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

private struct ContentChangeOperation {

    var context: FetchedResultsChangeContext
    var type: NSFetchedResultsChangeType
    var indexSet: IndexSet?
    var indexPath: IndexPath?
    var newIndexPath: IndexPath?

    init(type: NSFetchedResultsChangeType, indexSet: IndexSet) {
        self.context = .section
        self.type = type
        self.indexSet = indexSet
    }

    init(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        self.context = .object
        self.type = type
        self.indexPath = indexPath
        self.newIndexPath = newIndexPath
    }

}

private enum FetchedResultsChangeContext {
    case section
    case object
}
