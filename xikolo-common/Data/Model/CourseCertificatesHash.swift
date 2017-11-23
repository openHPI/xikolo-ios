//
//  CourseCertificatesHash.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 22.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

final class CourseCertificatesHash : NSObject, NSCoding, IncludedPullable {

    var available: Bool
    var threshold: Int32?

    required init(object: ResourceData) throws {
        self.available = try object.value(for: "available")
        self.threshold = try object.value(for: "threshold")
    }

    required init(coder decoder: NSCoder) {
        available = decoder.decodeBool(forKey: "available")
        threshold = decoder.decodeObject(forKey: "threshold") as? Int32
    }

    func encode(with coder: NSCoder) {
        coder.encode(available, forKey: "available")
        coder.encode(threshold, forKey: "threshold")
    }
    
}
