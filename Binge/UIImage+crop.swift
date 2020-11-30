//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIImage {

    func cropped(to targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / self.size.width
        let heightRatio = targetSize.height / self.size.height

        let scaleFactor = max(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: self.size.width * scaleFactor,
            height: self.size.height * scaleFactor
        )

        let offset = CGPoint(
            x: (scaledImageSize.width - targetSize.width) / 2 * -1,
            y: (scaledImageSize.height - targetSize.height) / 2 * -1
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: targetSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: offset,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }

}
