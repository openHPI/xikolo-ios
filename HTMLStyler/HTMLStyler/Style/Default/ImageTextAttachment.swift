//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

class ImageTextAttachment: NSTextAttachment {

    override func attachmentBounds(for textContainer: NSTextContainer?,
                                   proposedLineFragment lineFrag: CGRect,
                                   glyphPosition position: CGPoint,
                                   characterIndex charIndex: Int) -> CGRect {
        guard let image = self.image, image.size.width != 0, image.size.height != 0 else { return CGRect.zero }

        let scalingFactor = min(1, lineFrag.width / image.size.width)
        return CGRect(x: 0, y: 0, width: image.size.width * scalingFactor, height: image.size.height * scalingFactor)
    }

}
