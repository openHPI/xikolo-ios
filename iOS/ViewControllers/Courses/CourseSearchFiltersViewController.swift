//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

protocol CourseSearchFiltersViewControllerDelegate: AnyObject {
    func didChangeFilters()
}

class CourseSearchFiltersViewController: UICollectionViewController {

    private(set) var activeFilters: [CourseSearchFilter: Set<String>] = [:] {
        didSet {
            self.collectionView.reloadData()
            self.delegate?.didChangeFilters()
        }
    }

    weak var delegate: CourseSearchFiltersViewControllerDelegate?

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        super.init(collectionViewLayout: flowLayout)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.preservesSuperviewLayoutMargins = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white

        self.collectionView.register(R.nib.courseSearchFilterCell)
    }

    func clearFilters() {
        self.activeFilters = [:]
        self.collectionView.reloadSections(IndexSet([0]))
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfAdditionalCells = self.activeFilters.isEmpty ? 0 : 1
        return CourseSearchFilter.availableCases.count + numberOfAdditionalCells
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.courseSearchFilterCell, for: indexPath)!

        if indexPath.item == CourseSearchFilter.availableCases.count { // last cell / clear cell
            cell.configureAppearance(normalState: true)
            cell.titleLabel.text = "Clear"
        } else {
            let filter = CourseSearchFilter.availableCases[indexPath.item]
            let selectedOptions = self.activeFilters[filter]
            cell.configure(for: filter, with: selectedOptions)
        }


        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == CourseSearchFilter.availableCases.count { // last cell / clear cell
            self.clearFilters()
        } else {
            let filter = CourseSearchFilter.availableCases[indexPath.item]
            let selectedOptions = self.activeFilters[filter]
            let optionsViewController = CourseSearchFilterOptionsViewController(filter: filter, selectedOptions: selectedOptions, delegate: self)
            let navigationController = UINavigationController(rootViewController: optionsViewController)
            self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
        }
    }


}

extension CourseSearchFiltersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left
        var rightPadding = collectionView.layoutMargins.right

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
    }

}

extension CourseSearchFiltersViewController: CourseSearchFilterOptionsViewControllerDelegate {
    func setOptions(_ selectedOptions: Set<String>?, for filter: CourseSearchFilter) {
        self.activeFilters[filter] = selectedOptions
    }
}
