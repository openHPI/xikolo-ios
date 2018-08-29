//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol CourseListLayoutDelegate: AnyObject {

    var showHeaders: Bool { get }

    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withBoundingWidth boundingWidth: CGFloat) -> CGFloat

    // only needed in iOS 10
    func topInset() -> CGFloat

}

class CourseListLayout: UICollectionViewLayout {

    weak var delegate: CourseListLayoutDelegate?

    private var cellPadding: CGFloat = 0
    private var linePadding: CGFloat = 20
    private var headerHeight: CGFloat = 50

    private var cache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var sectionRange: [Int: (minimum: CGFloat, maximum: CGFloat)] = [:]
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }

        let layoutInsets = self.layoutInsets(for: collectionView)
        return collectionView.bounds.width - layoutInsets.left - layoutInsets.right
    }

    private func layoutInsets(for collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.delegate?.topInset() ?? 0,
                            left: collectionView.layoutMargins.left - 14,
                            bottom: 0,
                            right: collectionView.layoutMargins.right - 14)
    }

    private func numberOfColumms(for collectionView: UICollectionView) -> Int {
        if collectionView.traitCollection.horizontalSizeClass == .regular {
            return collectionView.bounds.width > 960 ? 3 : 2
        } else if collectionView.bounds.width > collectionView.bounds.height {
            return 2
        } else {
            return 1
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }

    override func prepare() {
        super.prepare()

        guard self.cache.isEmpty, let collectionView = collectionView else {
            return
        }

        let numberOfColumns = self.numberOfColumms(for: collectionView)
        let columnWidth = (self.contentWidth - CGFloat(max(0, numberOfColumns - 1)) * cellPadding) / CGFloat(numberOfColumns)
        let layoutInsets = self.layoutInsets(for: collectionView)

        var xOffset = [CGFloat]()
        var yOffset = [CGFloat]()
        for columnIndex in 0 ..< numberOfColumns {
            xOffset.append(layoutInsets.left + CGFloat(columnIndex) * (columnWidth + self.cellPadding))
            yOffset.append(layoutInsets.top - self.linePadding)
        }

        var rowOffset: CGFloat = 0
        let numberOfSections = collectionView.numberOfSections
        for section in 0 ..< numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            guard numberOfItems > 0 else { continue }

            var column = 0
            let sectionStart: CGFloat = (yOffset.max() ?? 0.0) + self.linePadding

            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: section)

                if column == 0 {
                    rowOffset = (yOffset.max() ?? 0.0) + self.linePadding
                }

                if item == 0, self.delegate?.showHeaders ?? true { // new section
                    rowOffset += self.headerHeight
                }

                let height = self.delegate?.collectionView(collectionView,
                                                           heightForCellAtIndexPath: indexPath,
                                                           withBoundingWidth: columnWidth) ?? 0
                let frame = CGRect(x: xOffset[column], y: rowOffset, width: columnWidth, height: height)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                self.cache[indexPath] = attributes

                self.contentHeight = max(self.contentHeight, frame.maxY + self.cellPadding)
                yOffset[column] = rowOffset + height

                column = column < (numberOfColumns - 1) ? (column + 1) : 0
            }

            let sectionEnd = (yOffset.max() ?? 0.0) + self.linePadding
            self.sectionRange[section] = (minimum: sectionStart, maximum: sectionEnd)
        }
    }

    override func invalidateLayout() {
        self.contentHeight = 0
        self.cache.removeAll()
        self.sectionRange.removeAll()
        super.invalidateLayout()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let sectionsToAdd = NSMutableIndexSet()
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []

        for layoutAttribute in self.cache.values.filter({ $0.frame.intersects(rect) }) {
            if layoutAttribute.representedElementCategory == .cell {
                layoutAttributes.append(layoutAttribute)
                sectionsToAdd.add(layoutAttribute.indexPath.section)
            } else if layoutAttribute.representedElementCategory == .supplementaryView {
                sectionsToAdd.add(layoutAttribute.indexPath.section)
            }
        }

        if self.delegate?.showHeaders ?? true {
            for section in sectionsToAdd {
                let indexPath = IndexPath(item: 0, section: section)
                let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath)
                if let sectionAttributes = attributes, sectionAttributes.frame.intersects(rect) {
                    layoutAttributes.append(sectionAttributes)
                }
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard self.delegate?.showHeaders ?? true else { return nil }
        guard elementKind == UICollectionElementKindSectionHeader else { return nil }

        guard let sectionRange = self.sectionRange[indexPath.section] else { return nil }
        guard let collectionView = collectionView else { return nil }

        let contentOffsetY: CGFloat
        if #available(iOS 11.0, *) {
            contentOffsetY = collectionView.contentOffset.y + collectionView.safeAreaInsets.top
        } else {
            let navigationBarHeight = (self.delegate as? UIViewController)?.topLayoutGuide.length ?? 64
            contentOffsetY = collectionView.contentOffset.y + navigationBarHeight
        }

        let offsetY: CGFloat
        if contentOffsetY < sectionRange.minimum {
            offsetY = sectionRange.minimum
        } else if contentOffsetY > sectionRange.maximum - self.headerHeight {
            offsetY = sectionRange.maximum - self.headerHeight
        } else {
            offsetY = contentOffsetY
        }

        let frame = CGRect(x: 0, y: offsetY, width: collectionView.bounds.width, height: self.headerHeight)
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
        layoutAttributes.frame = frame
        layoutAttributes.isHidden = false
        layoutAttributes.zIndex = 1

        return layoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let shouldInvalidate = super.shouldInvalidateLayout(forBoundsChange: newBounds)
        let invalidationContext = self.invalidationContext(forBoundsChange: newBounds)
        self.invalidateLayout(with: invalidationContext)
        return shouldInvalidate || self.collectionView?.bounds.width != newBounds.width
    }

}
