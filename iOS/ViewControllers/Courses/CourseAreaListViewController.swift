//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseAreaListViewController: UICollectionViewController {

    weak var delegate: CourseAreaListViewControllerDelegate?

    private var selectedIndexPath: IndexPath? {
        didSet {
            if let oldIndexPath = oldValue {
                self.collectionView?.deselectItem(at: oldIndexPath, animated: trueUnlessReduceMotionEnabled)
            }

            if let newIndexPath = self.selectedIndexPath {
                self.collectionView?.selectItem(at: newIndexPath, animated: trueUnlessReduceMotionEnabled, scrollPosition: .centeredHorizontally)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.allowsMultipleSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionViewLayout.invalidateLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.selectItem(at: self.selectedIndexPath, animated: animated, scrollPosition: .centeredHorizontally)

        if #available(iOS 11, *) {} else {
            self.collectionViewLayout.invalidateLayout()
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate?.accessibleAreas.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseIdentifier = R.reuseIdentifier.courseAreaCell.identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        if let cell = cell as? CourseAreaCell, let content = self.delegate?.accessibleAreas[safe: indexPath.item] {
            cell.configure(for: content)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }

        for selectedIndexPath in selectedIndexPaths where selectedIndexPath != indexPath {
            collectionView.deselectItem(at: selectedIndexPath, animated: true)
        }

        guard let selectedIndexPath = self.selectedIndexPath, indexPath != selectedIndexPath else { return }
        guard let content = self.delegate?.accessibleAreas[safe: indexPath.item] else { return }

        self.delegate?.change(to: content)
        self.selectedIndexPath = indexPath
    }

    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.collectionViewLayout.invalidateLayout()
        }) { _ in // swiftlint:disable:this multiple_closures_with_trailing_closure
            if let selectedIndexPath = self.selectedIndexPath {
                self.collectionView?.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: trueUnlessReduceMotionEnabled)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.calculatePreferredSize()
    }

    private func calculatePreferredSize() {
        let numberOfAreas = self.delegate?.accessibleAreas.count ?? 0
        let height = numberOfAreas > 1 ? self.cellHeight + 2 * 4 : 0
        let contentSize = CGSize(width: self.collectionView.contentSize.width, height: height)
        self.preferredContentSize = contentSize
    }

    func refresh() {
        self.collectionView?.reloadData()
        self.selectedIndexPath = {
            guard let content = self.delegate?.selectedArea else { return nil }
            guard let index = self.delegate?.accessibleAreas.firstIndex(of: content) else { return nil }
            return IndexPath(item: index, section: 0)
        }()
    }

}

extension CourseAreaListViewController: UICollectionViewDelegateFlowLayout {

    private var font: UIFont {
        return CourseAreaCell.font(whenSelected: true)
    }

    private var cellHeight: CGFloat {
        return self.font.lineHeight + 2 * 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleText = self.delegate?.accessibleAreas[safe: indexPath.item]?.title ?? ""
        let boundingSize = CGSize(width: CGFloat.infinity, height: self.cellHeight)
        let titleAttributes = [NSAttributedString.Key.font: self.font]
        let titleSize = NSString(string: titleText).boundingRect(with: boundingSize,
                                                                 options: .usesLineFragmentOrigin,
                                                                 attributes: titleAttributes,
                                                                 context: nil)

        return CGSize(width: titleSize.width + self.cellHeight / 2, height: self.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftPadding = collectionView.layoutMargins.left
        let rightPadding = collectionView.layoutMargins.right

        guard collectionView.traitCollection.horizontalSizeClass != .compact else {
            return UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
        }

        let numberOfItemsInSection = self.collectionView(collectionView, numberOfItemsInSection: section)
        var widthOfCells: CGFloat = 0
        for index in 0 ..< numberOfItemsInSection {
            let indexPath = IndexPath(item: index, section: section)
            let itemSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            widthOfCells += itemSize.width
        }

        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let cellGaps = (flowLayout?.minimumInteritemSpacing ?? 0) * CGFloat(numberOfItemsInSection - 1)
        let horizontalPadding = max(0, (collectionView.frame.size.width - widthOfCells - cellGaps - leftPadding - rightPadding) / 2)

        return UIEdgeInsets(top: 0, left: leftPadding + horizontalPadding, bottom: 0, right: rightPadding + horizontalPadding)
    }

}

protocol CourseAreaListViewControllerDelegate: AnyObject {
    var accessibleAreas: [CourseArea] { get }
    var selectedArea: CourseArea? { get }

    func change(to content: CourseArea)
}
