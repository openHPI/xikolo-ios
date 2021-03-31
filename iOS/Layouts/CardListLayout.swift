//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol CardListLayoutDelegate: AnyObject {

    var followReadableWidth: Bool { get }
    var topInset: CGFloat { get }
    var cardInset: CGFloat { get }
    var heightForHeader: CGFloat { get }
    var kindForGlobalHeader: String? { get }
    var heightForGlobalHeader: CGFloat { get }

    func minimalCardWidth(for traitCollection: UITraitCollection) -> CGFloat
    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat

}

extension CardListLayoutDelegate {

    var followReadableWidth: Bool {
        return false
    }

    var topInset: CGFloat {
        return 0
    }

    var cardInset: CGFloat {
        return 0
    }

    var heightForHeader: CGFloat {
        return 0
    }

    var kindForGlobalHeader: String? {
        return nil
    }

    var heightForGlobalHeader: CGFloat {
        return 0
    }

}

class CardListLayout: TopAlignedCollectionViewFlowLayout {

    weak var delegate: CardListLayoutDelegate?

//    private let cellPadding: CGFloat = 0
//    private let linePadding: CGFloat = 6

//    private var cache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
//    private var sectionRange: [Int: (minimum: CGFloat, maximum: CGFloat)] = [:]
//    private var contentHeight: CGFloat = 0

//    private var contentWidth: CGFloat {
//        guard let collectionView = self.collectionView else {
//            return 0
//        }
//
//        let layoutInsets = self.layoutInsets(for: collectionView)
//        return collectionView.bounds.width - layoutInsets.left - layoutInsets.right
//    }
//
//    private func layoutInsets(for collectionView: UICollectionView) -> UIEdgeInsets {
//        let followReadableWidth = self.delegate?.followReadableWidth ?? false
//        let guide = followReadableWidth ? collectionView.readableContentGuide : collectionView.layoutMarginsGuide
//        let layoutFrame = guide.layoutFrame
//        let cardInset = self.delegate?.cardInset ?? 0
//        return UIEdgeInsets(top: self.delegate?.topInset ?? 0,
//                            left: layoutFrame.minX - cardInset,
//                            bottom: 8,
//                            right: collectionView.bounds.width - layoutFrame.maxX - cardInset)
//    }
//
//    private func numberOfColumns(for collectionView: UICollectionView) -> Int {
//        guard let minimalCardWidth = self.delegate?.minimalCardWidth(for: collectionView.traitCollection) else {
//            return 1
//        }
//
//        let numberOfColumns = Int(floor(self.contentWidth / minimalCardWidth))
//        return max(1, numberOfColumns)
//    }
//
    override var collectionViewContentSize: CGSize {
        let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0
        let headerHeight = self.delegate?.heightForHeader ?? 0
        let numberOfSections = self.collectionView?.numberOfSections ?? 0
        var contentSize = super.collectionViewContentSize
        contentSize.height += globalHeaderHeight + CGFloat(numberOfSections) * headerHeight
        return contentSize
//        return CGSize(width: (self.collectionView?.bounds.width ?? 0), height: (self.collectionView?.bounds.height ?? 0) + (self.delegate?.heightForGlobalHeader ?? 0))
    }
//
//    // swiftlint:disable:next function_body_length
//    override func prepare() {
//        super.prepare()
//
//        guard self.cache.isEmpty, let collectionView = collectionView else {
//            return
//        }
//
//        let numberOfColumns = self.numberOfColumns(for: collectionView)
//        let columnWidth = (self.contentWidth - CGFloat(max(0, numberOfColumns - 1)) * self.cellPadding) / CGFloat(numberOfColumns)
//        let layoutInsets = self.layoutInsets(for: collectionView)
//
//        let xOffsetForColumn: (Int) -> CGFloat
//        if UIView.userInterfaceLayoutDirection(for: collectionView.semanticContentAttribute) == .rightToLeft {
//            xOffsetForColumn = {
//                let widthOfLeadingColumns = CGFloat($0 + 1) * columnWidth
//                let widthOfLeadingPaddings = CGFloat($0) * self.cellPadding
//                return collectionView.bounds.width - layoutInsets.right - widthOfLeadingColumns - widthOfLeadingPaddings
//            }
//        } else {
//            xOffsetForColumn = { layoutInsets.left + CGFloat($0) * (columnWidth + self.cellPadding) }
//        }
//
//        let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0
//
//        let xOffset = (0 ..< numberOfColumns).map(xOffsetForColumn)
//        var yOffset = [CGFloat](repeating: layoutInsets.top - self.linePadding + globalHeaderHeight, count: numberOfColumns)
//
//        var rowOffset: CGFloat = 0
//        let numberOfSections = collectionView.numberOfSections
//        for section in 0 ..< numberOfSections {
//            let numberOfItems = collectionView.numberOfItems(inSection: section)
//            guard numberOfItems > 0 else { continue }
//
//            var column = 0
//            let sectionStart: CGFloat = (yOffset.max() ?? 0.0) + self.linePadding
//
//            for item in 0 ..< numberOfItems {
//                let indexPath = IndexPath(item: item, section: section)
//
//                if column == 0 {
//                    rowOffset = (yOffset.max() ?? 0.0) + self.linePadding
//                }
//
//                // new section
//                if item == 0, let headerHeight = self.delegate?.heightForHeader, headerHeight > 0 {
//                    let cardInset = self.delegate?.cardInset ?? 0
//                    rowOffset += headerHeight - cardInset
//                }
//
//                let height = self.delegate?.collectionView(collectionView,
//                                                           heightForCellAtIndexPath: indexPath,
//                                                           withBoundingWidth: columnWidth) ?? 0
//                let frame = CGRect(x: xOffset[column], y: rowOffset, width: columnWidth, height: height)
//
//                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//                attributes.frame = frame
//                self.cache[indexPath] = attributes
//
//                self.contentHeight = max(self.contentHeight, frame.maxY + self.cellPadding)
//                yOffset[column] = rowOffset + height
//
//                column = column < (numberOfColumns - 1) ? (column + 1) : 0
//            }
//
//            let sectionEnd = (yOffset.max() ?? 0.0) + self.linePadding
//            self.sectionRange[section] = (minimum: sectionStart, maximum: sectionEnd)
//        }
//
//        self.contentHeight += layoutInsets.bottom
//    }
//
//    override func invalidateLayout() {
//        self.contentHeight = 0
//        self.cache.removeAll()
//        self.sectionRange.removeAll()
//        super.invalidateLayout()
//    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)

        let sectionsToAdd = NSMutableIndexSet()
//        var layoutAttributes: [UICollectionViewLayoutAttributes] = []

        let headerHeight = self.delegate?.heightForHeader ?? 0
        let topInset = self.delegate?.topInset ?? 0
        let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0

        layoutAttributes?.forEach { layoutAttribute in
            sectionsToAdd.add(layoutAttribute.indexPath.section)

            if layoutAttribute.representedElementCategory == .cell {
                layoutAttribute.frame = layoutAttribute.frame.offsetBy(
                    dx: 0,
                    dy: CGFloat(layoutAttribute.indexPath.section + 1) * (headerHeight) + topInset + globalHeaderHeight
                )
            }
        }


//        for layoutAttribute in attributes {
//            if layoutAttribute.representedElementCategory == .cell {
//                layoutAttributes.append(layoutAttribute)
//                sectionsToAdd.add(layoutAttribute.indexPath.section)
//            } else if layoutAttribute.representedElementCategory == .supplementaryView {
//                sectionsToAdd.add(layoutAttribute.indexPath.section)
//            }
//        }

        if let headerHeight = self.delegate?.heightForHeader, headerHeight > 0 {
            for section in sectionsToAdd {
                let indexPath = IndexPath(item: 0, section: section)
                let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
                if let sectionAttributes = attributes, sectionAttributes.frame.intersects(rect) {
                    layoutAttributes?.append(sectionAttributes)
                }
            }
        }

        if let globalHeaderKind = self.delegate?.kindForGlobalHeader, let globalHeaderHeight = self.delegate?.heightForGlobalHeader, globalHeaderHeight > 0 {
            if let headerLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: globalHeaderKind, at: IndexPath(item: 0, section: 0)) {
                layoutAttributes?.append(headerLayoutAttributes)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }

        if layoutAttributes.representedElementCategory == .cell {
            let headerHeight = self.delegate?.heightForHeader ?? 0
            let topInset = self.delegate?.topInset ?? 0
            let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0

            layoutAttributes.frame = layoutAttributes.frame.offsetBy(
                dx: 0,
                dy: CGFloat(indexPath.section + 1) * headerHeight + topInset + globalHeaderHeight
            )
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            guard let headerHeight = self.delegate?.heightForHeader, headerHeight > 0 else { return nil }

            guard let boundaries = self.boundaries(forSection: indexPath.section) else { return nil }
            guard let collectionView = collectionView else { return nil }

            let contentOffsetY: CGFloat
            if #available(iOS 11.0, *) {
                contentOffsetY = collectionView.contentOffset.y + collectionView.safeAreaInsets.top
            } else {
                let navigationBarHeight = (self.delegate as? UIViewController)?.topLayoutGuide.length ?? 64
                contentOffsetY = collectionView.contentOffset.y + navigationBarHeight
            }

            var offsetY: CGFloat
            if contentOffsetY < boundaries.minimum {
                offsetY = boundaries.minimum
            } else if contentOffsetY > boundaries.maximum - headerHeight {
                offsetY = boundaries.maximum - headerHeight
            } else {
                offsetY = contentOffsetY
            }



            let frame = CGRect(x: 0, y: offsetY, width: collectionView.bounds.width, height: headerHeight)
            let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
            layoutAttributes.frame = frame
            layoutAttributes.isHidden = false
            layoutAttributes.zIndex = 1
            return layoutAttributes
        } else {
            guard let collectionView = collectionView else { return nil }

            let height = self.delegate?.heightForGlobalHeader ?? 0
            let frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: height)
            let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            layoutAttributes.frame = frame
            return layoutAttributes
        }
    }

    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))

        guard let collectionView = collectionView else { return result }
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        guard numberOfItems > 0 else { return result }

        let layoutAttributes = (0..<numberOfItems).compactMap { self.layoutAttributesForItem(at: IndexPath(item: $0, section: section)) }
        result.minimum = layoutAttributes.map(\.frame.minY).min() ?? 0
        result.maximum = layoutAttributes.map(\.frame.maxY).max() ?? 0

        // Take Header Size Into Account
        result.minimum -= self.delegate?.heightForHeader ?? 0
//        result.maximum -= self.delegate?.heightForHeader ?? 0

        // Take Section Inset Into Account
//        result.minimum -= sectionInset.top
//        result.maximum += (sectionInset.top + sectionInset.bottom)

        return result
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let shouldInvalidate = super.shouldInvalidateLayout(forBoundsChange: newBounds)
        let invalidationContext = self.invalidationContext(forBoundsChange: newBounds)
        self.invalidateLayout(with: invalidationContext)
        return shouldInvalidate || self.collectionView?.bounds.width != newBounds.width
    }

}
