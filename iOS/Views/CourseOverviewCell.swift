//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseOverviewCell: UITableViewCell {

    enum Configuration {
        case currentCourses
        case completedCourses

        var title: String {
            switch self {
            case .currentCourses:
                return NSLocalizedString("dashboard.course-overview.My current courses", comment: "headline for overview of current courses")
            case .completedCourses:
                return NSLocalizedString("dashboard.course-overview.My completed courses", comment: "headline for overview of completed courses")
            }
        }

        var fetchRequest: NSFetchRequest<Course> {
            switch self {
            case .currentCourses:
                return CourseHelper.FetchRequest.enrolledCurrentCoursesRequest
            case .completedCourses:
                return CourseHelper.FetchRequest.completedCourses
            }
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var dataSource: CoreDataCollectionViewDataSource<CourseOverviewCell>!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView?.register(R.nib.courseCell(), forCellWithReuseIdentifier: R.reuseIdentifier.courseCell.identifier)
        self.collectionView.delegate = self
    }

    func configure(for configuration: Configuration) {
        self.titleLabel.text = configuration.title
        self.configureCollectionView(for: configuration)
    }

    private func configureCollectionView(for configuration: Configuration) {
        let request = configuration.fetchRequest
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        let reuseIdentifier = R.reuseIdentifier.courseCell.identifier
        self.dataSource = CoreDataCollectionViewDataSource(self.collectionView,
                                                           fetchedResultsControllers: [resultsController],
                                                           cellReuseIdentifier: reuseIdentifier,
                                                           delegate: self)
    }

}

extension CourseOverviewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = self.dataSource.object(at: indexPath)
        AppNavigator.show(course: course)
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
        let height: CGFloat = 12 + 150 + 8 + 20.5 + 4 + 18 // (image height + padding + text + padding + text)
        let availableWidth = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let width = min(availableWidth * 0.9, 300)
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

}
