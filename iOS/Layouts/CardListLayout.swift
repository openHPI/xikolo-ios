//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol CardListLayoutDelegate: AnyObject {

    var topInset: CGFloat { get }
    var heightForSectionHeader: CGFloat { get }
    var kindForGlobalHeader: String? { get }
    var heightForGlobalHeader: CGFloat { get }

}

extension CardListLayoutDelegate {

    var topInset: CGFloat {
        return 0
    }

    var heightForSectionHeader: CGFloat {
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

    private var topInset: CGFloat { self.delegate?.topInset ?? 0 }
    private var heightForSectionHeader: CGFloat { self.delegate?.heightForSectionHeader ?? 0 }
    private var kindForGlobalHeader: String? { self.delegate?.kindForGlobalHeader }
    private var heightForGlobalHeader: CGFloat { self.delegate?.heightForGlobalHeader ?? 0 }

    override var collectionViewContentSize: CGSize {
        let numberOfSections = self.collectionView?.numberOfSections ?? 0
        let heightForHeaders = CGFloat(numberOfSections) * self.heightForSectionHeader
        var contentSize = super.collectionViewContentSize
        contentSize.height += self.topInset + self.heightForGlobalHeader + heightForHeaders
        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let newRect = rect.offsetBy(dx: 0, dy: (self.topInset + self.heightForGlobalHeader) * -1)

        let originalLayoutAttributes = super.layoutAttributesForElements(in: newRect)
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        let sectionsToAdd = NSMutableIndexSet()

        originalLayoutAttributes?.forEach { originalLayoutAttribute in
            sectionsToAdd.add(originalLayoutAttribute.indexPath.section)

            if originalLayoutAttribute.representedElementCategory == .cell {
                // swiftlint:disable:next force_cast
                let layoutAttribute = originalLayoutAttribute.copy() as! UICollectionViewLayoutAttributes
                layoutAttribute.frame = layoutAttribute.frame.offsetBy(
                    dx: 0,
                    dy: CGFloat(layoutAttribute.indexPath.section + 1) * (self.heightForSectionHeader) + self.topInset + self.heightForGlobalHeader
                )
                layoutAttributes.append(layoutAttribute)
            }
        }

        if let headerHeight = self.delegate?.heightForSectionHeader, headerHeight > 0 {
            for section in sectionsToAdd {
                let indexPath = IndexPath(item: 0, section: section)
                let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
                if let sectionAttributes = attributes, sectionAttributes.frame.intersects(rect) {
                    layoutAttributes.append(sectionAttributes)
                }
            }
        }

        if let globalHeaderKind = self.kindForGlobalHeader, self.heightForGlobalHeader > 0 {
            if let headerLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: globalHeaderKind, at: IndexPath(item: 0, section: 0)) {
                layoutAttributes.append(headerLayoutAttributes)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let originalLayoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }

        if originalLayoutAttributes.representedElementCategory == .cell {
            // swiftlint:disable:next force_cast
            let layoutAttributes = originalLayoutAttributes.copy() as! UICollectionViewLayoutAttributes
            layoutAttributes.frame = layoutAttributes.frame.offsetBy(
                dx: 0,
                dy: CGFloat(indexPath.section + 1) * self.heightForSectionHeader + self.topInset + self.heightForGlobalHeader
            )
            return layoutAttributes
        } else {
            return originalLayoutAttributes
        }

    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            guard self.heightForSectionHeader > 0 else { return nil }
            guard let boundaries = self.boundaries(forSection: indexPath.section) else { return nil }
            guard let collectionView = collectionView else { return nil }

            let contentOffsetY = collectionView.contentOffset.y + collectionView.safeAreaInsets.top

            var offsetY: CGFloat
            if contentOffsetY < boundaries.minimum {
                // normal position
                offsetY = boundaries.minimum
            } else if contentOffsetY > boundaries.maximum - self.heightForSectionHeader {
                // position when moving out of the screen
                offsetY = boundaries.maximum - self.heightForSectionHeader
            } else {
                // sticky position
                offsetY = contentOffsetY
            }

            let frame = CGRect(x: 0, y: offsetY, width: collectionView.bounds.width, height: self.heightForSectionHeader)
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

        result.minimum -= self.delegate?.heightForSectionHeader ?? 0
        result.minimum = max(result.minimum, 0)

        return result
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override class var invalidationContextClass: AnyClass {
        return StickyHeaderInvalidationContext.self
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        // swiftlint:disable:next force_cast
        let context = super.invalidationContext(forBoundsChange: newBounds) as! StickyHeaderInvalidationContext

        guard self.collectionView?.bounds.width == newBounds.width else { return context }

        // Invalidate only section headers
        context.onlyHeaders = true
        let numberOfSections = self.collectionView?.numberOfSections ?? 0
        let sectionIndices = (0..<numberOfSections).map { IndexPath(item: 0, section: $0) }
        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndices)
        return context
    }

}

class StickyHeaderInvalidationContext: UICollectionViewFlowLayoutInvalidationContext {
    var onlyHeaders = false
    override var invalidateEverything: Bool { return !onlyHeaders }
    override var invalidateDataSourceCounts: Bool { return false }
}
