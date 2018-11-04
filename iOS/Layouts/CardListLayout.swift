//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

protocol CardListLayoutDelegate: AnyObject {

    var followReadableWidth: Bool { get }
    var showHeaders: Bool { get }
    var topInset: CGFloat { get } // only needed in iOS 10

    func minimalCardWidth(for traitCollection: UITraitCollection) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withBoundingWidth boundingWidth: CGFloat) -> CGFloat

}

extension CardListLayoutDelegate {

    var followReadableWidth: Bool {
        return false
    }

    var showHeaders: Bool {
        return false
    }

    var topInset: CGFloat {
        return 0
    }

}

class CardListLayout: UICollectionViewLayout {

    weak var delegate: CardListLayoutDelegate?

    private let cellPadding: CGFloat = 0
    private let linePadding: CGFloat = 6
    private let headerHeight: CGFloat = 36
    private let headerPillHeight: CGFloat = 50

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
        let followReadableWidth = self.delegate?.followReadableWidth ?? false
        let guide = followReadableWidth ? collectionView.readableContentGuide : collectionView.layoutMarginsGuide
        let layoutFrame = guide.layoutFrame
        return UIEdgeInsets(top: self.delegate?.topInset ?? 0,
                            left: layoutFrame.minX - 14,
                            bottom: 8,
                            right: collectionView.bounds.width - layoutFrame.maxX - 14)
    }

    private func numberOfColumms(for collectionView: UICollectionView) -> Int {
        guard let minimalCardWidth = self.delegate?.minimalCardWidth(for: collectionView.traitCollection) else {
            return 1
        }

        let numberOfColumns = Int(floor(self.contentWidth / minimalCardWidth))
        return max(1, numberOfColumns)
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
        let columnWidth = (self.contentWidth - CGFloat(max(0, numberOfColumns - 1)) * self.cellPadding) / CGFloat(numberOfColumns)
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

                if item == 0, self.delegate?.showHeaders ?? false { // new section
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

            self.contentHeight += layoutInsets.bottom
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
                let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
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
        guard elementKind == UICollectionView.elementKindSectionHeader else { return nil }

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

        let frame = CGRect(x: 0, y: offsetY, width: collectionView.bounds.width, height: self.headerPillHeight)
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
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
