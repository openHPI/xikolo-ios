//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import UIKit

extension AVMetadataItem {

    class func item(_ identifier: AVMetadataIdentifier, value: String?) -> AVMetadataItem? {
        guard var str = value else {
            return nil
        }
        // HACKHACK: Fix description to prevent visual bug in metadata display.
        if identifier == AVMetadataIdentifier.commonIdentifierDescription && str.count < 212 {
            str += String(repeating: " ", count: 131) + "\n\n\n" + String(repeating: " ", count: 183)
        }

        let item = AVMutableMetadataItem()
        item.value = str as NSString
        item.identifier = identifier
        item.extendedLanguageTag = "und" // Undefined language
        return item.copy() as? AVMetadataItem
    }

    class func artworkItem(_ image: UIImage) -> AVMetadataItem? {
        let item = AVMutableMetadataItem()
        item.value = UIImagePNGRepresentation(image) as (NSCopying & NSObjectProtocol)?
        item.dataType = kCMMetadataBaseDataType_PNG as String
        item.identifier = AVMetadataIdentifier.commonIdentifierArtwork
        item.extendedLanguageTag = "und" // Undefined language
        return item.copy() as? AVMetadataItem
    }

}
