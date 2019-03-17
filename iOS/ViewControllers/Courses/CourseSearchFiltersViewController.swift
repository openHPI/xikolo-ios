//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseSearchFiltersViewController: UICollectionViewController {

    private let availableFilterTypes: [CourseSearchFilter.Type] = [
        CourseLanguageSearchFilter.self,
    ]

    private var activeSelection: [String: CourseSearchFilter] = [
        CourseLanguageSearchFilter.title: CourseLanguageSearchFilter(selectedOptions: ["de"]),
    ]

    var activeFilters: [CourseSearchFilter] {
        return Array(self.activeSelection.values)
    }

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        super.init(collectionViewLayout: flowLayout)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.preservesSuperviewLayoutMargins = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.collectionView.backgroundColor = .white

        self.collectionView.register(R.nib.courseSearchFilterCell)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availableFilterTypes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.courseSearchFilterCell, for: indexPath)!

        let filterType = self.availableFilterTypes[indexPath.item]
        let filter = self.activeSelection[filterType.title]
        cell.configure(for: filterType, with: filter)

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

}

extension CourseSearchFiltersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        #warning("use self sizing cells?")
        let filterType = self.availableFilterTypes[indexPath.item]
        let filter = self.activeSelection[filterType.title]
        return CourseSearchFilterCell.size(for: filterType, with: filter)
    }

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
