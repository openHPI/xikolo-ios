//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let originalAttributes = super.layoutAttributesForElements(in: rect)
        var attributes: [UICollectionViewLayoutAttributes] = []

        originalAttributes?.reduce(into: [CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
            guard $1.representedElementCategory == .cell else { return }
            $0.merge([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                (min($0.0, $1.0), $0.1 + $1.1)
            }
        }.values.forEach { minY, attributesInLine in
            attributesInLine.forEach { originalAttribute in
                // swiftlint:disable:next force_cast
                let attribute = originalAttribute.copy() as! UICollectionViewLayoutAttributes
                attribute.frame = attribute.frame.offsetBy(
                    dx: 0,
                    dy: minY - attribute.frame.origin.y
                )
                attributes.append(attribute)
            }
        }

        return attributes
    }

}
