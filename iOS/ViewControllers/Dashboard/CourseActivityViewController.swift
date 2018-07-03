//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import DZNEmptyDataSet
import Foundation
import UIKit

class CourseActivityViewController: UICollectionViewController {

    var resultsController: NSFetchedResultsController<Course>!
    var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<Course>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = CourseHelper.FetchRequest.enrolledCourses
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        let reuseIdentifier = R.reuseIdentifier.lastCourseCell.identifier
        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(self.collectionView,
                                                                                                        resultsControllers: [resultsController],
                                                                                                        cellReuseIdentifier: reuseIdentifier)
        let configuration = CourseActivityViewConfiguration().wrapped
        resultsControllerDelegateImplementation.configuration = configuration
        resultsController.delegate = resultsControllerDelegateImplementation
        self.collectionView?.dataSource = resultsControllerDelegateImplementation

        do {
            try resultsController.performFetch()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error(error)
        }
    }

}

extension CourseActivityViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = resultsController.object(at: indexPath)
        AppNavigator.show(course: course)
    }

}

extension CourseActivityViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 150 + 6 + 20.5 + 4 + 18 // (image height + padding + text + padding + text)
        var width = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            width -= 4 * flowLayout.minimumInteritemSpacing
        }

        width = min(width, 300)

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath())
        let numberOfCellsInSection = CGFloat(self.resultsController?.sections?[section].numberOfObjects ?? 0)
        let viewWidth = self.collectionView?.frame.size.width ?? 0
        var horizontalPadding = max(0, (viewWidth - numberOfCellsInSection * cellSize.width) / 2)

        if #available(iOS 11.0, *) {
            // nothing to do here
        } else {
            horizontalPadding += 20
        }

        return UIEdgeInsets(top: 0, left: horizontalPadding, bottom: 0, right: horizontalPadding)
    }

}

struct CourseActivityViewConfiguration: CollectionViewResultsControllerConfiguration {

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<Course>, indexPath: IndexPath) {
        let cell = cell.require(toHaveType: CourseCell.self, hint: "CourseActivityViewController requires cell of type CourseCell")
        let course = controller.object(at: indexPath)
        cell.configure(course, forConfiguration: .courseActivity)
    }

}
