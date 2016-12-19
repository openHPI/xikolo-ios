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
        if let cv = self.collectionView {

            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;

            if let attributesForVisibleCells = self.layoutAttributesForElementsInRect(cvBounds) {

                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {

                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != .Cell {
                        continue
                    }

                    if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }

                    // == First time in the loop == //
                    guard let candAttrs = candidateAttributes else {
                        candidateAttributes = attributes
                        continue
                    }

                    let a = attributes.center.x - proposedContentOffsetCenterX
                    let b = candAttrs.center.x - proposedContentOffsetCenterX

                    if fabsf(Float(a)) < fabsf(Float(b)) {
                        candidateAttributes = attributes;
                    }
                }

                // Beautification step , I don't know why it works!
                if(proposedContentOffset.x == -(cv.contentInset.left)) {
                    return proposedContentOffset
                }

                return CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
            }
        }

        // fallback
        return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
    }
    
}
