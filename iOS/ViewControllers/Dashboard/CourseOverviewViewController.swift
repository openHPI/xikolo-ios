//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseOverviewViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var buttonToCompleteList: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    private var courses: [Course] = [] {
        didSet {
            self.collectionView.reloadData()
            self.updateCollectionViewHeight()
            self.buttonToCompleteList.isHidden = self.courses.count <= self.itemLimit
        }
    }

    private let itemLimit = 6

    var configuration: CourseListConfiguration!

    private func refresh() {
        guard let fetchRequest = self.configuration.resultsControllers.first?.fetchRequest else { return }
        // Fetch one additional item. In this way, we know that there are more courses in the list and we should the 'Show All Courses' card.
        fetchRequest.fetchLimit = self.itemLimit + 1
        let result = CoreDataHelper.viewContext.fetchMultiple(fetchRequest)
        self.courses = result.value ?? []
    }

    private func shareCourse(at indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath)
        let course = self.courses[indexPath.item]
        let activityViewController = UIActivityViewController.make(for: course, on: self)
        activityViewController.popoverPresentationController?.sourceView = cell
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    private func showCourseDates(course: Course) {
        let courseDatesViewController = R.storyboard.courseDates.instantiateInitialViewController().require()
        courseDatesViewController.course = course
        let navigationController = CustomWidthNavigationController(rootViewController: courseDatesViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.configuration.title

        self.collectionView.register(R.nib.courseCell)
        self.collectionView.register(R.nib.pseudoCourseCell)

        self.refresh()

        self.adjustScrollDirection()
        self.updateCollectionViewHeight()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCollectionViewHeight),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)

        if #available(iOS 11.0, *) {
            self.collectionView.dragDelegate = self
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.courseOverviewViewController.showCompleteList(segue: segue) {
            typedInfo.destination.configuration = self.configuration
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // swiftlint:disable:next trailing_closure
        coordinator.animate(alongsideTransition: { _ in
            self.updateCollectionViewHeight()
        })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.adjustScrollDirection()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    @available(iOS 11, *)
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        self.updateCollectionViewHeight()
    }

    @objc private func updateCollectionViewHeight() {
        let courseCellWidth = CourseCell.minimalWidthInOverviewList(for: self.collectionView.traitCollection)
        let availableWidth = self.view.bounds.width - self.view.layoutMargins.left - self.view.layoutMargins.right + 2 * CourseCell.cardInset

        let itemsPerRow = floor(availableWidth / courseCellWidth)
        let numberOfItems = CGFloat(self.collectionView(self.collectionView, numberOfItemsInSection: 0))

        let numberOfRows: CGFloat = {
            if self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular {
                return ceil(numberOfItems / itemsPerRow)
            } else {
                return 1
            }
        }()

        let preferredWidth: CGFloat = {
            if self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular {
                return availableWidth / itemsPerRow
            } else {
                return min(availableWidth * 0.9, courseCellWidth)
            }
        }()

        let height = CourseCell.heightForOverviewList(forWidth: preferredWidth) * numberOfRows
        self.collectionViewHeightConstraint.constant = ceil(height)
    }

    private func adjustScrollDirection() {
        let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let fullRegularSizeClass = self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular
        flowLayout?.scrollDirection = fullRegularSizeClass ? .vertical : .horizontal
    }

    @IBAction private func showCompleteList() {
        self.performSegue(withIdentifier: R.segue.courseOverviewViewController.showCompleteList, sender: nil)
    }

    @objc private func coreDataChange(notification: Notification) {
        let courseChanged = notification.includesChanges(for: Course.self)
        let enrollmentRefreshed = notification.includesChanges(for: Enrollment.self, key: .refreshed)

        if courseChanged || enrollmentRefreshed {
            self.refresh()
        }
    }

}

extension CourseOverviewViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let courseCount = self.courses.count

        if courseCount == 0 {
            return 1
        } else if courseCount > self.itemLimit {
            return self.itemLimit
        } else {
            return courseCount
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.courses.isEmpty {
            let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.pseudoCourseCell, for: indexPath)
            let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(PseudoCourseCell.self)")
            cell.configure(for: .emptyCourseOverview, configuration: self.configuration)
            return cell
        } else {
            let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.courseCell, for: indexPath)
            let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(CourseCell.self)")
            let course = self.courses[indexPath.item]
            cell.configure(course, for: .courseOverview)
            return cell
        }
    }

}

extension CourseOverviewViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.courses.isEmpty {
            self.appNavigator?.showCourseList()
        } else {
            let course = self.courses[indexPath.item]
            self.appNavigator?.show(course: course, userInitiated: false)
        }
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.item < self.itemLimit else { return nil }

        let course = self.courses[indexPath.item]

        ErrorManager.shared.remember(course.id, forKey: "course_overview_list-latest_course_preview")

        let previewProvider: UIContextMenuContentPreviewProvider = {
            return R.storyboard.coursePreview().instantiateInitialViewController { coder in
                return CoursePreviewViewController(coder: coder, course: course, listConfiguration: self.configuration)
            }
        }

        let actionProvider: UIContextMenuActionProvider = { _ in
            let userActions = [
                course.showCourseDatesAction { [weak self] in self?.showCourseDates(course: course) },
                course.shareAction { [weak self] in self?.shareCourse(at: indexPath) },
            ].compactMap { $0 }

            return UIMenu(title: "", children: userActions.asActions())
        }

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: previewProvider, actionProvider: actionProvider)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            let course = self.courses[indexPath.item]
            self.appNavigator?.show(course: course, userInitiated: false)
        }
    }

}

extension CourseOverviewViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let courseCellWidth = CourseCell.minimalWidthInOverviewList(for: collectionView.traitCollection)
        let availableWidth = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right + 2 * CourseCell.cardInset
        let itemsPerRow = floor(availableWidth / courseCellWidth)

        let preferredWidth: CGFloat = {
            if self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular {
                return availableWidth / itemsPerRow
            } else {
                return min(availableWidth * 0.9, courseCellWidth)
            }
        }()

        let height = CourseCell.heightForOverviewList(forWidth: preferredWidth)
        return CGSize(width: preferredWidth, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left - CourseCell.cardInset
        var rightPadding = collectionView.layoutMargins.right - CourseCell.cardInset

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
    }

}

@available(iOS 11.0, *)
extension CourseOverviewViewController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return [] }
        let selectedCourse = self.courses[indexPath.item]
        let courseCell = collectionView.cellForItem(at: indexPath) as? CourseCell
        return [selectedCourse.dragItem(with: courseCell?.previewView)]
    }

}
