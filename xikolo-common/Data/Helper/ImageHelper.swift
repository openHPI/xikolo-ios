//
//  ImageHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ImageHelper {

    class func loadImageFromURL(_ url: URL, toImageView imageView: UIImageView) {
        ImageProvider.loadImage(url).onSuccess { image in
            imageView.image = image
        }
    }

}
