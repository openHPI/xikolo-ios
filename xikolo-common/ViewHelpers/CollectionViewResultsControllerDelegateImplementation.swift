//
//  CollectionViewResultsControllerDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CollectionViewResultsControllerDelegateImplementation<T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate, UICollectionViewDataSource {

    weak var collectionView: UICollectionView?
    var resultsControllers: [NSFetchedResultsController<T>] = [] // 2Think: Do we create a memory loop here?
    var cellReuseIdentifier: String
    var headerReuseIdentifier: String?

    var searchFetchRequest: NSFetchRequest<T>?
    var searchFetchResultsController: NSFetchedResultsController<T>?

    var configuration: CollectionViewResultsControllerConfigurationWrapper<T>?
    private var contentChangeOperations: [BlockOperation] = []

    required init(_ collectionView: UICollectionView?,
                  resultsControllers: [NSFetchedResultsController<T>],
                  searchFetchRequest: NSFetchRequest<T>? = nil,
                  cellReuseIdentifier: String) {
        self.collectionView = collectionView
        self.resultsControllers = resultsControllers
        self.searchFetchRequest = searchFetchRequest
        self.cellReuseIdentifier = cellReuseIdentifier

        let nib = UINib(nibName: "EmptyCollectionViewCell", bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "EmptyCell")
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
//        let convertedIndexSet: IndexSet
//        if self.searchFetchResultsController == controller {
//            convertedIndexSet = IndexSet(integer: sectionIndex)
//        } else if self.searchFetchResultsController == nil {
//            convertedIndexSet = self.indexSet(for: controller, with: IndexSet(integer: sectionIndex))!
//        } else {
//            return
//        }

        guard self.searchFetchResultsController == nil else { return }

        let convertedIndexSet = self.indexSet(for: controller, with: IndexSet(integer: sectionIndex))!

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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard self.searchFetchResultsController == nil else { return }

        let convertedIndexPath = self.indexPath(for: controller, with: indexPath)
        let convertedNewIndexPath = self.indexPath(for: controller, with: newIndexPath)

//        let convertedIndexPath: IndexPath?
//        let convertedNewIndexPath: IndexPath?
//        if self.searchFetchResultsController == controller {
//            convertedIndexPath = indexPath
//            convertedNewIndexPath = newIndexPath
//        } else if self.searchFetchResultsController == nil {
//            convertedIndexPath = self.indexPath(for: controller, with: indexPath)
//            convertedNewIndexPath = self.indexPath(for: controller, with: newIndexPath)
//        } else {
//            return
//        }

        switch type {
        case .insert:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [convertedNewIndexPath!])
            }))
        case .delete:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.deleteItems(at: [convertedIndexPath!])
            }))
        case .update:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.reloadItems(at: [convertedIndexPath!])
            }))
        case .move:
            self.contentChangeOperations.append(BlockOperation(block: {
                self.collectionView?.deleteItems(at: [convertedIndexPath!])
                self.collectionView?.insertItems(at: [convertedNewIndexPath!])
            }))
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard self.searchFetchResultsController == nil else { return }

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
        if self.searchFetchResultsController != nil {
            return 1
        } else {
            return self.resultsControllers.map { $0.sections?.count ?? 0 }.reduce(0, +)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let searchResultsController = self.searchFetchResultsController {
            return max(searchResultsController.fetchedObjects?.count ?? 0, 1)
        } else {
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
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.searchFetchResultsController?.fetchedObjects?.isEmpty ?? false {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        if let searchResultsController = self.searchFetchResultsController {
            self.configuration?.configureCollectionCell(cell, for: searchResultsController, indexPath: indexPath)
        } else {
            let (controller, newIndexPath) = self.controllerAndImplementationIndexPath(forVisual: indexPath)! // TODO nil-handling or logging
            self.configuration?.configureCollectionCell(cell, for: controller, indexPath: newIndexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier!, for: indexPath)
            if let searchResultsController = self.searchFetchResultsController {
                if let numberOfSearchResults = searchResultsController.fetchedObjects?.count {
                    self.configuration?.configureSearchHeaderView(view, numberOfSearchResults: numberOfSearchResults)
                }
            } else {
                let (controller, newIndexPath) = controllerAndImplementationIndexPath(forVisual: indexPath)!
                if let section = controller.sections?[newIndexPath.section] {
                    self.configuration?.configureCollectionHeaderView(view, section: section)
                }
            }
            return view
        } else {
            return UICollectionReusableView()
        }
    }

    func search(withText searchText: String) {
        guard let fetchRequest = self.searchFetchRequest?.copy() as? NSFetchRequest<T> else {
            print("Warning: CollectionViewControllerDelegateImplementation is not configured for search. Missing search fetch request.")
            self.resetSearch()
            return
        }

        guard !searchText.isEmpty else {
            self.resetSearch()
            return
        }

        let searchPredicate = self.configuration?.searchPredicate(forSearchText: searchText)
        let fetchPredicate = fetchRequest.predicate
        let predicates = [fetchPredicate, searchPredicate].flatMap { $0 }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        self.searchFetchResultsController = CoreDataHelper.createResultsController(fetchRequest, sectionNameKeyPath: nil)
        try? self.searchFetchResultsController?.performFetch()
        self.collectionView?.reloadData()
    }

    func resetSearch() {
        let shouldReloadData = self.searchFetchResultsController != nil
        self.searchFetchResultsController = nil
        if shouldReloadData {
            self.collectionView?.reloadData()
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

    func searchPredicate(forSearchText searchText: String) -> NSPredicate?
    func configureSearchHeaderView(_ view: UICollectionReusableView, numberOfSearchResults: Int)

}

extension CollectionViewResultsControllerConfiguration {

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {}

    func searchPredicate(forSearchText searchText: String) -> NSPredicate? {
        return nil
    }

    func configureSearchHeaderView(_ view: UICollectionReusableView, numberOfSearchResults: Int) {}

}

// This is a wrapper for type erasure allowing the generic CollectionViewResultsControllerDelegateImplementation to be
// configured with a concrete type (via a configuration struct).
class CollectionViewResultsControllerConfigurationWrapper<T: NSManagedObject>: CollectionViewResultsControllerConfiguration {

    private let configureCollectionCell: (UICollectionViewCell, NSFetchedResultsController<T>, IndexPath) -> Void
    private let configureCollectionHeaderView: (UICollectionReusableView, NSFetchedResultsSectionInfo) -> Void
    private let searchPredicate: (String) -> NSPredicate?
    private let configureSearchHeaderView: (UICollectionReusableView, Int) -> Void

    required init<U: CollectionViewResultsControllerConfiguration>(_ configuration: U) where U.Content == T {
        self.configureCollectionCell = configuration.configureCollectionCell
        self.configureCollectionHeaderView = configuration.configureCollectionHeaderView
        self.searchPredicate = configuration.searchPredicate
        self.configureSearchHeaderView = configuration.configureSearchHeaderView
    }

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<T>, indexPath: IndexPath) {
        self.configureCollectionCell(cell, controller, indexPath)
    }

    func configureCollectionHeaderView(_ view: UICollectionReusableView, section: NSFetchedResultsSectionInfo) {
        self.configureCollectionHeaderView(view, section)
    }

    func searchPredicate(forSearchText searchText: String) -> NSPredicate? {
        return self.searchPredicate(searchText)
    }

    func configureSearchHeaderView(_ view: UICollectionReusableView, numberOfSearchResults: Int) {
        self.configureSearchHeaderView(view, numberOfSearchResults)
    }

}
