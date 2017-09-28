//
//  AVMetaDataItem+creation.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 20.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import AVFoundation
import UIKit

extension AVMetadataItem {

    class func item(_ identifier: String, value: String?) -> AVMetadataItem? {
        guard var str = value else {
            return nil
        }
        // HACKHACK: Fix description to prevent visual bug in metadata display.
        if identifier == AVMetadataIdentifier.commonIdentifierDescription.rawValue && str.characters.count < 212 {
            str = str + "                                                                                                                                  \n\n\n                                                                                                                                                                                     "
        }

        let item = AVMutableMetadataItem()
        item.value = str as NSString
        item.identifier = AVMetadataIdentifier(rawValue: identifier)
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
