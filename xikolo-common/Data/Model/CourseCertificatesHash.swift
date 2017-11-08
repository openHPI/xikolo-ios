//
//  CourseCertificatesHash.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 22.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import Marshal

@objc
final class CourseCertificatesHash : NSObject, NSCoding, Unmarshaling {
//class CourseCertificatesHash : NSObject, NSCoding, EmbeddedObject {

    var available: Bool // TODO: should be Bool
    var threshold: Int32? // TODO: should be Int32?

//    required init(_ dict: [String : AnyObject]) {
//        available = dict["available"] as? Bool
//        threshold = dict["threshold"] as? NSNumber
//    }

    required init(object: MarshaledObject) throws {
        self.available = try object.value(for: "available")
        self.threshold = try object.value(for: "threshold")
    }

    required init(coder decoder: NSCoder) {
        available = decoder.decodeObject(forKey: "available") as! Bool // TODO: force cast
        threshold = decoder.decodeObject(forKey: "threshold") as? Int32
    }

    func encode(with coder: NSCoder) {
        coder.encode(available, forKey: "available")
        coder.encode(threshold, forKey: "threshold")
    }
    
}

//extension CourseCertificatesHash: ValueType {
//
//    init(available: Bool?, threshold: NSNumber?) {
//        self.available = available
//        self.threshold = threshold
//    }
//
//    public static func value(from object: Any) throws -> CourseCertificates {
//        guard let dict = object as? JSONObject else {
//            throw MarshalError.typeMismatch(expected: JSONObject.self, actual: type(of: object))
//        }
//
//        let available = try object.value(forKey: "available") as Bool?
//        let threshold = try object.value(forKey: "available") as NSNumner?
//
//        return CourseCertificatesHash(available: available, threshold: threshold)
//    }
//
//}

//extension CourseCertificatesHash: Unmarshaling {
//
//    required init(object: MarshaledObject) throws {
//        self.available = try object.value(for: "available")
////        self.threshold = try object.value(for: "threshold")
//    }
//
//}

