//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol CardListLayoutDelegate: AnyObject {

    var topInset: CGFloat { get }
    var cardInset: CGFloat { get }
    var heightForHeader: CGFloat { get }
    var kindForGlobalHeader: String? { get }
    var heightForGlobalHeader: CGFloat { get }

}

extension CardListLayoutDelegate {

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

    override var collectionViewContentSize: CGSize {
        let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0
        let headerHeight = self.delegate?.heightForHeader ?? 0
        let numberOfSections = self.collectionView?.numberOfSections ?? 0
        let topInset = self.delegate?.topInset ?? 0
        var contentSize = super.collectionViewContentSize
        contentSize.height += globalHeaderHeight + CGFloat(numberOfSections) * headerHeight + topInset
        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let headerHeight = self.delegate?.heightForHeader ?? 0
        let topInset = self.delegate?.topInset ?? 0
        let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0
        let newRect = rect.offsetBy(dx: 0, dy: (topInset + globalHeaderHeight) * -1)

        let originalLayoutAttributes = super.layoutAttributesForElements(in: newRect)
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        let sectionsToAdd = NSMutableIndexSet()

        originalLayoutAttributes?.forEach { originalLayoutAttribute in
            sectionsToAdd.add(originalLayoutAttribute.indexPath.section)

            if originalLayoutAttribute.representedElementCategory == .cell {
                let layoutAttribute = originalLayoutAttribute.copy() as! UICollectionViewLayoutAttributes
                layoutAttribute.frame = layoutAttribute.frame.offsetBy(
                    dx: 0,
                    dy: CGFloat(layoutAttribute.indexPath.section + 1) * (headerHeight) + topInset + globalHeaderHeight
                )
                layoutAttributes.append(layoutAttribute)
            }
        }

        if let headerHeight = self.delegate?.heightForHeader, headerHeight > 0 {
            for section in sectionsToAdd {
                let indexPath = IndexPath(item: 0, section: section)
                let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
                if let sectionAttributes = attributes, sectionAttributes.frame.intersects(rect) {
                    layoutAttributes.append(sectionAttributes)
                }
            }
        }

        if let globalHeaderKind = self.delegate?.kindForGlobalHeader, let globalHeaderHeight = self.delegate?.heightForGlobalHeader, globalHeaderHeight > 0 {
            if let headerLayoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: globalHeaderKind, at: IndexPath(item: 0, section: 0)) {
                layoutAttributes.append(headerLayoutAttributes)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let originalLayoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }

        if originalLayoutAttributes.representedElementCategory == .cell {
            let headerHeight = self.delegate?.heightForHeader ?? 0
            let topInset = self.delegate?.topInset ?? 0
            let globalHeaderHeight = self.delegate?.heightForGlobalHeader ?? 0

            let layoutAttributes = originalLayoutAttributes.copy() as! UICollectionViewLayoutAttributes
            layoutAttributes.frame = layoutAttributes.frame.offsetBy(
                dx: 0,
                dy: CGFloat(indexPath.section + 1) * headerHeight + topInset + globalHeaderHeight
            )
            return layoutAttributes
        } else {
            return originalLayoutAttributes
        }

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

        result.minimum -= self.delegate?.heightForHeader ?? 0

        return result
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
        let shouldInvalidate = super.shouldInvalidateLayout(forBoundsChange: newBounds)
        return shouldInvalidate || self.collectionView?.bounds.width != newBounds.width
    }

}
