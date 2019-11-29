//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseOverviewViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!

    private var courses: [Course] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private let itemLimit = 5

    var configuration: CourseListConfiguration!

    private func refresh() {
        guard let fetchRequest = self.configuration.resultsControllers.first?.fetchRequest else { return }
        // Fetch one additional item. In this way, we know that there are more courses in the list and we should the 'Show All Courses' card.
        fetchRequest.fetchLimit = self.itemLimit + 1
        let result = CoreDataHelper.viewContext.fetchMultiple(fetchRequest)
        self.courses = result.value ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.configuration.title

        self.collectionView.register(R.nib.courseCell)
        self.collectionView.register(R.nib.pseudoCourseCell)

        self.refresh()

        self.updateCollectionViewHeight()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCollectionViewHeight),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.courseOverviewViewController.showCourseList(segue: segue) {
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
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    @objc private func updateCollectionViewHeight() {
        let courseCellWidth = CourseCell.minimalWidth(for: self.collectionView.traitCollection)
        let availableWidth = self.view.bounds.width - self.view.layoutMargins.left - self.view.layoutMargins.right
        let preferredWidth = min(availableWidth * 0.9, courseCellWidth)
        let height = CourseCell.heightForOverviewList(forWidth: preferredWidth)
        self.collectionViewHeightConstraint.constant = ceil(height)
    }

    @objc private func coreDataChange(notification: Notification) {
        guard notification.includesChanges(for: Course.self) else { return }
        self.refresh()
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
            return self.itemLimit + 1
        } else {
            return courseCount
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let courseCount = self.courses.count

        if courseCount == 0 {
            let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.pseudoCourseCell, for: indexPath)
            let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(PseudoCourseCell.self)")
            cell.configure(for: .emptyCourseOverview, configuration: self.configuration)
            return cell
        } else if courseCount > self.itemLimit, self.itemLimit == indexPath.item {
            let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.pseudoCourseCell, for: indexPath)
            let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(PseudoCourseCell.self)")
            cell.configure(for: .showAllCoursesOfOverview, configuration: self.configuration)
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
        if let course = self.courses[safe: indexPath.item], indexPath.item < self.itemLimit {
            self.appNavigator?.show(course: course)
        } else if self.courses.isEmpty {
            self.appNavigator?.showCourseList()
        } else {
            self.performSegue(withIdentifier: R.segue.courseOverviewViewController.showCourseList, sender: nil)
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
        let courseCellWidth = CourseCell.minimalWidth(for: collectionView.traitCollection)
        let availableWidth = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let preferedWidth = min(availableWidth * 0.9, courseCellWidth)

        let hasCourses = !self.courses.isEmpty
        let isLastCell = self.itemLimit == indexPath.item

        let width = hasCourses && isLastCell ? preferedWidth * 2 / 3 : preferedWidth
        let height = CourseCell.heightForOverviewList(forWidth: preferedWidth)

        return CGSize(width: width, height: height)
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
