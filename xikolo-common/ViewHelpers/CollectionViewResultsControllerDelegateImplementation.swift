//
//  CollectionViewResultsControllerDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CollectionViewResultsControllerDelegateImplementation : NSObject, NSFetchedResultsControllerDelegate {

    weak var collectionView: UICollectionView!
    weak var delegate: CollectionViewResultsControllerDelegateImplementationDelegate?
    private var contentChangeOperations: [ContentChangeOperation] = []

    required init(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        contentChangeOperations.removeAll()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexSet: NSIndexSet(index: sectionIndex)))
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexPath: indexPath, newIndexPath: newIndexPath))
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({
            let collectionView = self.collectionView!
            for change in self.contentChangeOperations {
                switch change.context {
                    case .Section:
                        switch change.type {
                            case .Insert:
                                collectionView.insertSections(change.indexSet!)
                            case .Delete:
                                collectionView.deleteSections(change.indexSet!)
                            case .Move:
                                break
                            case .Update:
                                break
                            }
                    case .Object:
                        switch change.type {
                            case .Insert:
                                collectionView.insertItemsAtIndexPaths([change.newIndexPath!])
                            case .Delete:
                                collectionView.deleteItemsAtIndexPaths([change.indexPath!])
                            case .Update:
                                // No need to update a cell that has not been loaded.
                                if let cell = collectionView.cellForItemAtIndexPath(change.indexPath!) {
                                    self.delegate?.configureCollectionCell(cell, indexPath: change.indexPath!)
                                }
                            case .Move:
                                collectionView.deleteItemsAtIndexPaths([change.indexPath!])
                                collectionView.insertItemsAtIndexPaths([change.newIndexPath!])
                        }
                }
            }
        }, completion: nil)
    }

}

protocol CollectionViewResultsControllerDelegateImplementationDelegate : class {

    func configureCollectionCell(cell: UICollectionViewCell, indexPath: NSIndexPath)

}

private struct ContentChangeOperation {

    var context: FetchedResultsChangeContext
    var type: NSFetchedResultsChangeType
    var indexSet: NSIndexSet?
    var indexPath: NSIndexPath?
    var newIndexPath: NSIndexPath?

    init(type: NSFetchedResultsChangeType, indexSet: NSIndexSet) {
        self.context = .Section
        self.type = type
        self.indexSet = indexSet
    }

    init(type: NSFetchedResultsChangeType, indexPath: NSIndexPath?, newIndexPath: NSIndexPath?) {
        self.context = .Object
        self.type = type
        self.indexPath = indexPath
        self.newIndexPath = newIndexPath
    }

}

private enum FetchedResultsChangeContext {
    case Section
    case Object
}
