//
//  CourseListLayout.swift
//  xikolo-ios
//
//  Created by Max Bothe on 05.12.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

protocol CourseListLayoutDelegate: class {

    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withBoundingWidth boundingWidth: CGFloat) -> CGFloat

}

class CourseListLayout: UICollectionViewLayout {

    weak var delegate: CourseListLayoutDelegate?

    private var cellPadding: CGFloat = 16
    private var linePadding: CGFloat = 24
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
        return UIEdgeInsets(top: 0,
                            left: max(self.cellPadding, collectionView.layoutMargins.left),
                            bottom: 0,
                            right: max(self.cellPadding, collectionView.layoutMargins.right))
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.contentWidth, height: self.contentHeight)
    }

    override func prepare() {
        super.prepare()

        guard self.cache.isEmpty, let collectionView = collectionView else {
            return
        }

        let numberOfColumns: Int
        if collectionView.traitCollection.horizontalSizeClass == .regular {
            numberOfColumns = collectionView.bounds.width > 960 ? 3 : 2
        } else {
            numberOfColumns = 1
        }

        let columnWidth = (self.contentWidth - CGFloat(max(0, numberOfColumns - 1)) * cellPadding) / CGFloat(numberOfColumns)
        let layoutInsetLeft = self.layoutInsets(for: collectionView).left

        var xOffset = [CGFloat]()
        var yOffset = [CGFloat]()
        for columnIndex in 0 ..< numberOfColumns {
            xOffset.append(layoutInsetLeft + CGFloat(columnIndex) * (columnWidth + self.cellPadding))
            yOffset.append(-self.linePadding)
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

                if item == 0 { // new section
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

        for section in sectionsToAdd {
            let indexPath = IndexPath(item: 0, section: section)
            if let sectionAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath), sectionAttributes.frame.intersects(rect) {
                layoutAttributes.append(sectionAttributes)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionElementKindSectionHeader else { return nil }

        guard let sectionRange = self.sectionRange[indexPath.section] else { return nil }
        guard let collectionView = collectionView else { return nil }

        let contentOffsetY: CGFloat
        if #available(iOS 11.0, *) {
            contentOffsetY = collectionView.contentOffset.y + collectionView.safeAreaInsets.top
        } else {
            contentOffsetY = collectionView.contentOffset.y + 64
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

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)

        // invalidate visible section headers
        var sectionsToInvalidate: Set<IndexPath> = []
        for layoutAttribute in self.cache.values.filter({ $0.frame.intersects(newBounds) }) {
            let indexPath = IndexPath(item: 0, section: layoutAttribute.indexPath.section)
            if layoutAttribute.representedElementCategory == .cell {
                sectionsToInvalidate.insert(indexPath)
            } else if layoutAttribute.representedElementCategory == .supplementaryView {
                sectionsToInvalidate.insert(indexPath)
            }
        }

        context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: sectionsToInvalidate.map { $0 })

        return context
    }

}
