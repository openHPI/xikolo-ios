//
//  ImageProvider.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Alamofire
import BrightFutures
import UIKit

class ImageProvider {

    class func loadImage(imageUrl: String) -> Future<UIImage, XikoloError> {
        let promise = Promise<UIImage, XikoloError>()
        Alamofire.request(.GET, imageUrl).responseData { response in
            if let error = response.result.error {
                promise.failure(XikoloError.Network(error))
                return
            }
            if let data = response.result.value {
                if let image = UIImage(data: data, scale: 1.0) {
                    promise.success(image)
                    return
                }
            }
            promise.failure(XikoloError.InvalidData)
        }
        return promise.future
    }

}
