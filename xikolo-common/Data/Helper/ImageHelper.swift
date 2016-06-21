//
//  ImageHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ImageHelper {

    class func loadImageFromURL(imageUrl: String, toImageView imageView: UIImageView) {
        ImageProvider.loadImage(imageUrl).onSuccess { image in
            imageView.image = image
        }
    }

}
