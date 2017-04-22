//
//  CourseCertificatesHash.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 22.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class CourseCertificatesHash : NSObject, NSCoding, EmbeddedObject {

    var available: Bool?
    var threshold: NSNumber?

    required init(_ dict: [String : AnyObject]) {
        available = dict["available"] as? Bool
        threshold = dict["threshold"] as? NSNumber
    }

    required init(coder decoder: NSCoder) {
        available = decoder.decodeObject(forKey: "available") as? Bool
        threshold = decoder.decodeObject(forKey: "threshold") as? NSNumber
    }

    func encode(with coder: NSCoder) {
        coder.encode(available, forKey: "available")
        coder.encode(threshold, forKey: "threshold")
    }
    
}
