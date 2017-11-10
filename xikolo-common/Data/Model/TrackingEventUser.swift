//
//  TrackingEventUser.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class TrackingEventUser : NSObject, NSCoding {

    var uuid: String

    init(uuid: String) {
        self.uuid = uuid
    }

    required init?(coder decoder: NSCoder) {
        guard let uuid = decoder.decodeObject(forKey: "uuid") as? String else {
            return nil
        }

        self.uuid = uuid
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.uuid, forKey: "uuid")
    }


//    required init(_ dict: [String : AnyObject]) {
//        if let uuid = dict["uuid"] as? String {
//            self.uuid = uuid
//        }
//    }
//
//    override init() {
//    }
//
//    func toDict() -> [String : AnyObject] {
//        var dict = [String: AnyObject]()
//        if let uuid = uuid {
//            dict["uuid"] = uuid as AnyObject?
//        }
//        return dict
//    }

}
