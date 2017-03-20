//
//  CollectionViewResultsControllerDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CollectionViewMultipleResultsControllerDelegateImplementation : NSObject, NSFetchedResultsControllerDelegate {

//    deinit {
//        resultsController = nil
//    }

    weak var collectionView: UICollectionView!
    var resultsController: [NSFetchedResultsController<NSFetchRequestResult>]
    var cellReuseIdentifier: String
    var headerReuseIdentifier: String?

    weak var delegate: CollectionViewMultipleResultsControllerDelegateImplementationDelegate?
    fileprivate var contentChangeOperations: [ContentChangeOperation] = []

    required init(_ collectionView: UICollectionView, resultsController: [NSFetchedResultsController<NSFetchRequestResult>], cellReuseIdentifier: String) {
        self.collectionView = collectionView
        self.resultsController = resultsController
        self.cellReuseIdentifier = cellReuseIdentifier
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        contentChangeOperations.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexSet: IndexSet(integer: sectionIndex)))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexPath: indexPath, newIndexPath: newIndexPath))
    }

    // TODO: Update to new
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({
            let collectionView = self.collectionView!
            for change in self.contentChangeOperations {
                switch change.context {
                    case .section:
                        switch change.type {
                            case .insert:
                                collectionView.insertSections(change.indexSet!) // Shit, I don't know what to do
                            case .delete:
                                collectionView.deleteSections(change.indexSet!)
                            case .move:
                                break
                            case .update:
                                break
                            }
                    case .object:
                        switch change.type {
                            case .insert:
                                collectionView.insertItems(at: [change.newIndexPath!])
                            case .delete:
                                collectionView.deleteItems(at: [change.indexPath!])
                            case .update:
                                // No need to update a cell that has not been loaded.
                                if let cell = collectionView.cellForItem(at: change.indexPath!) {
                                    self.delegate?.configureCollectionCell(cell, indexPath: change.indexPath!)
                                }
                            case .move:
                                collectionView.deleteItems(at: [change.indexPath!])
                                collectionView.insertItems(at: [change.newIndexPath!])
                        }
                }
            }
        }, completion: nil)
    }

}

extension CollectionViewMultipleResultsControllerDelegateImplementation : UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return resultsController.count 
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsController[section].sections?[0].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        self.delegate?.configureCollectionCell(cell, indexPath: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier!, for: indexPath)
            if let section = resultsController[indexPath.section].sections?[0] {
                delegate?.configureCollectionHeaderView?(view, section: section)
            }
            return view
        } else {
            fatalError("Unsupported supplementary view kind.")
        }
    }

}

@objc protocol CollectionViewMultipleResultsControllerDelegateImplementationDelegate : class {

    func configureCollectionCell(_ cell: UICollectionViewCell, indexPath: IndexPath)

    @objc optional func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo)

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
