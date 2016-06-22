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

    class func item(identifier: String, value: protocol<NSCopying, NSObjectProtocol>?) -> AVMetadataItem? {
        if var value = value {
            if let str = value as? String {
                // HACKHACK: Fix description to prevent visual bug in metadata display.
                if identifier == AVMetadataCommonIdentifierDescription && str.characters.count < 212 {
                    value = str.stringByAppendingString("                                                                                                                                  \n\n\n                                                                                                                                                                                     ")
                }
            }

            let item = AVMutableMetadataItem()
            item.value = value
            item.identifier = identifier
            item.extendedLanguageTag = "und" // Undefined language
            return item.copy() as? AVMetadataItem
        }
        return nil
    }

    class func artworkItem(image: UIImage) -> AVMetadataItem? {
        let item = AVMutableMetadataItem()
        item.value = UIImagePNGRepresentation(image)
        item.dataType = kCMMetadataBaseDataType_PNG as String
        item.identifier = AVMetadataCommonIdentifierArtwork
        item.extendedLanguageTag = "und" // Undefined language
        return item.copy() as? AVMetadataItem
    }

}
