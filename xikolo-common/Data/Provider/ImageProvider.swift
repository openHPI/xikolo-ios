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

    class func loadImage(_ url: URL) -> Future<UIImage, XikoloError> {
        let promise = Promise<UIImage, XikoloError>()
        Alamofire.request(url, method: .get).responseData { response in
            if let error = response.result.error {
                return promise.failure(XikoloError.network(error))
            }
            if let data = response.result.value {
                if let image = UIImage(data: data, scale: 1.0) {
                    return promise.success(image)
                }
            }
            return promise.failure(XikoloError.invalidData)
        }
        return promise.future
    }

}
