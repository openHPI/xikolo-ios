//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseContentListViewController : UICollectionViewController {

    private var selectedIndexPath: IndexPath?
    weak var delegate: CourseContentListViewControllerDelegate?

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CourseContent.orderedValues.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseIdentifier = "CourseAreaCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        if let cell = cell as? CourseContentCell {
            let content = CourseContent.orderedValues[indexPath.item]
            let isSelected = indexPath == self.selectedIndexPath
            cell.configure(for: content, isSelected: isSelected)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath != self.selectedIndexPath else { return }
        guard let content = CourseContent.orderedValues[safe: indexPath.item] else { return }

        if let selectedIndexPath = self.selectedIndexPath, let cell = collectionView.cellForItem(at: selectedIndexPath) as? CourseContentCell {
            cell.markAsSelected(false)
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? CourseContentCell {
            cell.markAsSelected(true)
            self.selectedIndexPath = indexPath
        }

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        self.delegate?.change(to: content)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionViewLayout.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let selectedIndexPath = self.selectedIndexPath {
            self.collectionView?.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
        }
    }

}

extension CourseContentListViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleText = CourseContent.orderedValues[indexPath.item].title
        let boundingSize = CGSize(width: CGFloat.infinity, height: 34)
        let titleAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
        let titleSize = NSString(string: titleText).boundingRect(with: boundingSize,
                                                                 options: .usesLineFragmentOrigin,
                                                                 attributes: titleAttributes,
                                                                 context: nil)
        return CGSize(width: titleSize.width + 2, height: 34)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let numberOfItemsInSection = self.collectionView(collectionView, numberOfItemsInSection: section)
        var widthOfCells: CGFloat = 0
        for index in 0 ..< numberOfItemsInSection {
            let indexPath = IndexPath(item: index, section: section)
            let itemSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            widthOfCells += itemSize.width
        }

        let cellGaps: CGFloat = ((collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0) * CGFloat(numberOfItemsInSection)
        widthOfCells += cellGaps
        let leftPadding: CGFloat = max(collectionView.layoutMargins.left, collectionView.superview?.layoutMargins.left ?? 0)
        let rightPadding: CGFloat = max(collectionView.layoutMargins.right, collectionView.superview?.layoutMargins.right ?? 0)
        let viewWidth = self.collectionView?.frame.size.width ?? 0
        let horizontalPadding = max(0, (viewWidth - leftPadding - rightPadding - widthOfCells) / 2)

        return UIEdgeInsets(top: 0, left: leftPadding + horizontalPadding, bottom: 0, right: rightPadding + horizontalPadding)
    }

}

protocol CourseContentListViewControllerDelegate: class {
    func change(to content: CourseContent)
}
