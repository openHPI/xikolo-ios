//
//  CenterCellCollectionViewFlowLayout.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 17.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit

class CenterCellCollectionViewFlowLayout : UICollectionViewFlowLayout {

    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if let collectionView = self.collectionView {

            let collectionViewBounds = collectionView.bounds
            let halfWidth = collectionViewBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;

            if let attributesForVisibleCells = self.layoutAttributesForElementsInRect(collectionViewBounds) {

                /*  == If we're at the beginning of the list, the item should be
                       aligned with the left content inset of the collectionView    == */
                if(proposedContentOffset.x == -(collectionView.contentInset.left)) {
                    return proposedContentOffset
                }

                //  == If not, we need to calculate the "snapping" center position  == //
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {

                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != .Cell {
                        continue
                    }

                    if (attributes.center.x == 0) || (attributes.center.x > (collectionView.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }

                    // == First time in the loop == //
                    guard let candAttrs = candidateAttributes else {
                        candidateAttributes = attributes
                        continue
                    }

                    let a = attributes.center.x - proposedContentOffsetCenterX
                    let b = candAttrs.center.x - proposedContentOffsetCenterX

                    if abs(Float(a)) < abs(Float(b)) {
                        candidateAttributes = attributes;
                    }
                }
                return CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
            }
        }

        // fallback
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
    
}
