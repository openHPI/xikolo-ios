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

    private var dataSource: CoreDataCollectionViewDataSource<CourseActivityViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.register(R.nib.courseCell(), forCellWithReuseIdentifier: R.reuseIdentifier.courseCell.identifier)

        let request = CourseHelper.FetchRequest.enrolledCourses
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        let reuseIdentifier = R.reuseIdentifier.courseCell.identifier
        self.dataSource = CoreDataCollectionViewDataSource(self.collectionView,
                                                           fetchedResultsControllers: [resultsController],
                                                           cellReuseIdentifier: reuseIdentifier,
                                                           delegate: self)
    }

}

extension CourseActivityViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = self.dataSource.object(at: indexPath)
        AppNavigator.show(course: course)
    }

}

extension CourseActivityViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 12 + 150 + 8 + 20.5 + 4 + 18 // (image height + padding + text + padding + text)
        let availableWidth = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let width = min(availableWidth * 0.9, 300)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath())
        let numberOfObjectsInSection = CGFloat(self.dataSource.collectionView(collectionView, numberOfItemsInSection: section))
        let viewWidth = self.collectionView?.frame.size.width ?? 0

        var leftPadding = collectionView.layoutMargins.left - 14
        var rightPadding = collectionView.layoutMargins.right - 14

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        let horizontalCenteredPadding = (viewWidth - numberOfObjectsInSection * cellSize.width) / 2
        leftPadding = max(leftPadding, horizontalCenteredPadding)
        rightPadding = max(leftPadding, horizontalCenteredPadding)

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
    }

}

extension CourseActivityViewController: CoreDataCollectionViewDataSourceDelegate {

    typealias HeaderView = UICollectionReusableView

    func configure(_ cell: CourseCell, for object: Course) {
        cell.configure(object, forConfiguration: .courseActivity)
    }

}
