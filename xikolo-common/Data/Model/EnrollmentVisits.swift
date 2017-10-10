//
//  EnrollmentVisits.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 19.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

@objcMembers
class EnrollmentVisits : NSObject, NSCoding, EmbeddedObject {

    var visited: NSNumber?
    var total: NSNumber?
    var percentage: NSNumber?

    required init(_ dict: [String : AnyObject]) {
        visited = dict["visited"] as? NSNumber
        total = dict["total"] as? NSNumber
        percentage = dict["percentage"] as? NSNumber
    }

    required init(coder decoder: NSCoder) {
        visited = decoder.decodeObject(forKey: "visited") as? NSNumber
        total = decoder.decodeObject(forKey: "total") as? NSNumber
        percentage = decoder.decodeObject(forKey: "percentage") as? NSNumber
    }

    func encode(with coder: NSCoder) {
        coder.encode(visited, forKey: "visited")
        coder.encode(total, forKey: "total")
        coder.encode(percentage, forKey: "percentage")
    }
    
}
