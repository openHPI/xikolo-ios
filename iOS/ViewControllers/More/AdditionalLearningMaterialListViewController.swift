//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//


import Common
import UIKit

class AdditionalLearningMaterialListViewController: UICollectionViewController {

    override func viewDidLoad() {
        self.collectionView?.register(R.nib.additionalLearningMaterialCell)

        super.viewDidLoad()

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
            self.collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let additionalLearningMaterial = Brand.default.additionalLearningMaterial

        if indexPath.item == additionalLearningMaterial.count {
            self.performSegue(withIdentifier: R.segue.additionalLearningMaterialListViewController.showNews, sender: self)
        } else {
            let url = additionalLearningMaterial[indexPath.item].url
            UIApplication.shared.open(url)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // swiftlint:disable:next trailing_closure
        coordinator.animate(alongsideTransition: { _  in
            self.navigationController?.navigationBar.sizeToFit()
            self.collectionViewLayout.invalidateLayout()
        })
    }

}

extension AdditionalLearningMaterialListViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Brand.default.additionalLearningMaterial.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.additionalLearningMaterialCell, for: indexPath)
        let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(AdditionalLearningMaterialCell.self)")

        let additionalLearningMaterialResources = Brand.default.additionalLearningMaterial

        if indexPath.item == additionalLearningMaterialResources.count {
            cell.configureNews()
        } else {
            cell.configure(for: additionalLearningMaterialResources[indexPath.item].type)
        }

        return cell
    }

}

extension AdditionalLearningMaterialListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let width = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        let height = 180 + 2 * AdditionalLearningMaterialCell.cardInset
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        var leftPadding = collectionView.layoutMargins.left - AdditionalLearningMaterialCell.cardInset
        var rightPadding = collectionView.layoutMargins.right - AdditionalLearningMaterialCell.cardInset

        if #available(iOS 11.0, *) {
            leftPadding -= collectionView.safeAreaInsets.left
            rightPadding -= collectionView.safeAreaInsets.right
        }

        return UIEdgeInsets(top: 4, left: leftPadding, bottom: collectionView.layoutMargins.bottom, right: rightPadding)
    }

}
