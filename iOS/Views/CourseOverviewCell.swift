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
                return "Your current courses"
            case .completedCourses:
                return "Your completed courses"
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

    private var fetchRequest: NSFetchRequest<Course>!
    private var resultsController: NSFetchedResultsController<Course>!
    private var resultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<Course>!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView?.register(R.nib.courseCell(), forCellWithReuseIdentifier: R.reuseIdentifier.courseCell.identifier)
        self.collectionView.delegate = self
    }

    func configure(for configuration: Configuration) {
        self.titleLabel.text = configuration.title
        self.fetchRequest = configuration.fetchRequest
        self.configureCollectionView()
    }

    private func configureCollectionView() {
        resultsController = CoreDataHelper.createResultsController(self.fetchRequest, sectionNameKeyPath: nil)

        let reuseIdentifier = R.reuseIdentifier.courseCell.identifier
        resultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(self.collectionView,
                                                                                                        resultsControllers: [resultsController],
                                                                                                        cellReuseIdentifier: reuseIdentifier)
        let configuration = CourseOverviewViewConfiguration().wrapped
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

extension CourseOverviewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = resultsController.object(at: indexPath)
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
        let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath())
        let numberOfCellsInSection = CGFloat(self.resultsController?.sections?[section].numberOfObjects ?? 0)
        let viewWidth = self.collectionView?.frame.size.width ?? 0

        var leftPadding = collectionView.layoutMargins.left - 14
        var rightPadding = collectionView.layoutMargins.right - 14

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        let horizontalCenteredPadding = (viewWidth - numberOfCellsInSection * cellSize.width) / 2
        leftPadding = max(leftPadding, horizontalCenteredPadding)
        rightPadding = max(leftPadding, horizontalCenteredPadding)

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
    }

}

struct CourseOverviewViewConfiguration: CollectionViewResultsControllerConfiguration {

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<Course>, indexPath: IndexPath) {
        let cell = cell.require(toHaveType: CourseCell.self, hint: "CourseOverviewViewController requires cell of type CourseCell")
        let course = controller.object(at: indexPath)
        cell.configure(course, forConfiguration: .courseOverview)
    }

}
