//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseOverviewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var configuration: CourseListConfiguration!
    private var dataSource: CoreDataCollectionViewDataSource<CourseOverviewCell>!

    weak var delegate: CourseOverviewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView?.register(R.nib.courseCell(), forCellWithReuseIdentifier: R.reuseIdentifier.courseCell.identifier)
        self.collectionView?.register(R.nib.pseudoCourseCell(), forCellWithReuseIdentifier: R.reuseIdentifier.pseudoCourseCell.identifier)
        self.collectionView.delegate = self
    }

    func configure(for configuration: CourseListConfiguration) {
        self.configuration = configuration
        self.titleLabel.text = configuration.title
        self.configureCollectionView(for: configuration)
    }

    private func configureCollectionView(for configuration: CourseListConfiguration) {
        let reuseIdentifier = R.reuseIdentifier.courseCell.identifier
        self.dataSource = CoreDataCollectionViewDataSource(self.collectionView,
                                                           fetchedResultsControllers: configuration.resultsControllers,
                                                           cellReuseIdentifier: reuseIdentifier,
                                                           delegate: self)
    }

}

extension CourseOverviewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let numberOfItemsInSection = self.dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        if numberOfItemsInSection - 1 == indexPath.item {
            if numberOfItemsInSection - 1 == 0 {
                AppNavigator.showCourseList()
            } else {
                self.delegate?.openCourseList(for: self.configuration)
            }
        } else {
            let course = self.dataSource.object(at: indexPath)
            AppNavigator.show(course: course)
        }
    }

}

extension CourseOverviewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 14 + 150 + 8 + 20.5 + 4 + 18 // (padding + image height + padding + text + padding + text)
        let numberOfItemsInSection = self.dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let maximalWidth: CGFloat = numberOfItemsInSection - 1 > 0 && numberOfItemsInSection - 1 == indexPath.item ? 200 : 300
        let availableWidth = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let width = min(availableWidth * 0.9, maximalWidth)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left - 14
        var rightPadding = collectionView.layoutMargins.right - 14

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
    }

}

extension CourseOverviewCell: CoreDataCollectionViewDataSourceDelegate {

    typealias HeaderView = UICollectionReusableView

    func configure(_ cell: CourseCell, for object: Course) {
        cell.configure(object, forConfiguration: .courseOverview)
    }

    func modifiedNumberOfItems(_ numberOfItems: Int, inSection section: Int) -> Int? {
        return numberOfItems + 1
    }

    func collectionView(_ collectionView: UICollectionView, injectedCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        let numberOfItemsInSection = self.dataSource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        guard numberOfItemsInSection - 1 == indexPath.item else {
            return nil
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.pseudoCourseCell, for: indexPath)
        let style: PseudoCourseCell.Style = numberOfItemsInSection - 1 == 0 ? .emptyCourseOverview : .showAllCoursesOfOverview
        cell?.configure(for: style, configuration: self.configuration)
        return cell
    }

}

protocol CourseOverviewDelegate: AnyObject {

    func openCourseList(for configuration: CourseListConfiguration)

}