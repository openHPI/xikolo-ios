//
//  ImageProvider.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 25.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Alamofire
import UIKit

class ImageProvider {

    class func loadImage(imageUrl: String, completion: (UIImage?, NSError?) -> ()) {
        Alamofire.request(.GET, imageUrl).responseData { response in
            if let data = response.result.value {
                let image = UIImage(data: data, scale: 1.0)
                completion(image, response.result.error)
            }
            completion(nil, response.result.error)
        }
    }

}
