//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseAreaListViewController: UICollectionViewController {

    weak var delegate: CourseAreaListViewControllerDelegate?

    private var shouldScrollToSelectedItem: Bool = false

    private var selectedIndexPath: IndexPath? {
        guard let content = self.delegate?.selectedArea else { return nil }
        guard let index = self.delegate?.accessibleContent.index(of: content) else { return nil }
        return IndexPath(item: index, section: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionViewLayout.invalidateLayout()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate?.accessibleContent.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseIdentifier = R.reuseIdentifier.courseAreaCell.identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        if let cell = cell as? CourseAreaCell, let content = self.delegate?.accessibleContent[safe: indexPath.item] {
            let selected = indexPath == self.selectedIndexPath
            cell.configure(for: content, selected: selected)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath != self.selectedIndexPath else { return }
        guard let content = self.delegate?.accessibleContent[safe: indexPath.item] else { return }

        self.delegate?.change(to: content)
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionViewLayout.invalidateLayout()
        self.shouldScrollToSelectedItem = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let selectedIndexPath = self.selectedIndexPath, self.shouldScrollToSelectedItem {
            self.collectionView?.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            self.shouldScrollToSelectedItem = false
        }
    }

    func refresh(animated: Bool) {
        self.collectionView?.reloadData()
        if let selectedIndexPath = self.selectedIndexPath {
            self.collectionView?.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
        }
    }

}

extension CourseAreaListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleText = self.delegate?.accessibleContent[safe: indexPath.item]?.title ?? ""
        let boundingSize = CGSize(width: CGFloat.infinity, height: 34)
        let titleAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
        let titleSize = NSString(string: titleText).boundingRect(with: boundingSize,
                                                                 options: .usesLineFragmentOrigin,
                                                                 attributes: titleAttributes,
                                                                 context: nil)
        return CGSize(width: titleSize.width + 2, height: 34) // 2pt extra to prevent the title for truncation
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

        let cellGaps: CGFloat = ((collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0) * CGFloat(numberOfItemsInSection - 1)
        widthOfCells += cellGaps
        let leftPadding: CGFloat = collectionView.layoutMargins.left
        let rightPadding: CGFloat = collectionView.layoutMargins.right
        let horizontalPadding = max(0, (collectionView.frame.size.width - widthOfCells) / 2 - leftPadding - rightPadding)

        return UIEdgeInsets(top: 0, left: leftPadding + horizontalPadding, bottom: 0, right: rightPadding + horizontalPadding)
    }

}

protocol CourseAreaListViewControllerDelegate: AnyObject {
    var accessibleContent: [CourseArea] { get }
    var selectedArea: CourseArea? { get }

    func change(to content: CourseArea)
}
