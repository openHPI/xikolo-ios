//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//


import Common
import UIKit

class MoreViewController: UICollectionViewController {

    override func viewDidLoad() {
        self.collectionView?.register(R.nib.moreCell)

        super.viewDidLoad()

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
            self.collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let additionalLearningMaterialResources = Brand.default.additionalLearningMaterialResources

        if indexPath.item == additionalLearningMaterialResources.count {
            self.performSegue(withIdentifier: R.segue.moreViewController.showNews, sender: self)
        } else {
            let url = additionalLearningMaterialResources[indexPath.item].url
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

extension MoreViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Brand.default.additionalLearningMaterialResources.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let someCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.moreCell, for: indexPath)
        let cell = someCell.require(hint: "Unexpected cell type at \(indexPath), expected cell of type \(MoreCell.self)")

        let additionalLearningMaterialResources = Brand.default.additionalLearningMaterialResources

        if indexPath.item == additionalLearningMaterialResources.count {
            cell.configureNews()
        } else {
            cell.configure(for: additionalLearningMaterialResources[indexPath.item].type)
        }

        return cell
    }

}

extension MoreViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let boundingWidth = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let height = CGFloat(180.0)
        return CGSize(width: boundingWidth, height: height)
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

        return UIEdgeInsets(top: 14, left: leftPadding, bottom: collectionView.layoutMargins.bottom, right: rightPadding)
    }

}
