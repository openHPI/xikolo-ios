//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

// swiftlint:disable:next type_name
class AdditionalLearningMaterialListViewController: UICollectionViewController {

    override func viewDidLoad() {
        self.view.preservesSuperviewLayoutMargins = true
        self.collectionView?.register(R.nib.additionalLearningMaterialCell)

        super.viewDidLoad()

        self.adjustScrollDirection()
        self.collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let additionalLearningMaterial = Brand.default.additionalLearningMaterial
        let url = additionalLearningMaterial[indexPath.item].url
        UIApplication.shared.open(url)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            self.navigationController?.navigationBar.sizeToFit()
            self.collectionViewLayout.invalidateLayout()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calculatePreferredSize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.adjustScrollDirection()
        self.collectionViewLayout.invalidateLayout()
    }

    private func calculatePreferredSize() {
        if self.traitCollection.horizontalSizeClass == .regular {
            self.preferredContentSize = CGSize(width: self.view.bounds.width, height: 180 + 2 * AdditionalLearningMaterialCell.cardInset)
        } else {
            self.preferredContentSize = self.collectionView.contentSize
        }
    }

    private func adjustScrollDirection() {
        let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = self.traitCollection.horizontalSizeClass == .regular ? .horizontal : .vertical
    }

}

extension AdditionalLearningMaterialListViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Brand.default.additionalLearningMaterial.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.additionalLearningMaterialCell, for: indexPath)
        let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(AdditionalLearningMaterialCell.self)")

        let additionalLearningMaterial = Brand.default.additionalLearningMaterial
        cell.configure(for: additionalLearningMaterial[indexPath.item])

        return cell
    }

}

extension AdditionalLearningMaterialListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        var availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        availableWidth -= collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right

        let height = 180 + 2 * AdditionalLearningMaterialCell.cardInset

        if self.traitCollection.horizontalSizeClass == .regular {
            let numberOfItems = CGFloat(self.collectionView(collectionView, numberOfItemsInSection: indexPath.section))
            if numberOfItems == 1 {
                let width = min(availableWidth, 360 + 2 * AdditionalLearningMaterialCell.cardInset)
                return CGSize(width: width, height: height)
            } else {
                let width = availableWidth / numberOfItems
                return CGSize(width: width, height: height)
            }
        } else {
            return CGSize(width: availableWidth, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftPadding = collectionView.layoutMargins.left - AdditionalLearningMaterialCell.cardInset - collectionView.safeAreaInsets.left
        let rightPadding = collectionView.layoutMargins.right - AdditionalLearningMaterialCell.cardInset - collectionView.safeAreaInsets.right
        return UIEdgeInsets(top: 4, left: leftPadding, bottom: collectionView.layoutMargins.bottom, right: rightPadding)
    }

}
