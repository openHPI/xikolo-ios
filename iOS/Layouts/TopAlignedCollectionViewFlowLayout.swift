//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        attributes?.reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
            guard $1.representedElementCategory == .cell else { return $0 }
            return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                (min($0.0, $1.0), $0.1 + $1.1)
            }
        }.values.forEach { minY, attributesInLine in
            attributesInLine.forEach {
                $0.frame = $0.frame.offsetBy(
                    dx: 0,
                    dy: minY - $0.frame.origin.y
                )
            }
        }

        return attributes
    }

}
