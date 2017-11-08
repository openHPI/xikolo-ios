//
//  TrackingEventUser.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class TrackingEventUser : NSObject, EmbeddedObject {

    var uuid: String?

    required init(_ dict: [String : AnyObject]) {
        if let uuid = dict["uuid"] as? String {
            self.uuid = uuid
        }
    }

    override init() {
    }

    func toDict() -> [String : AnyObject] {
        var dict = [String: AnyObject]()
        if let uuid = uuid {
            dict["uuid"] = uuid as AnyObject?
        }
        return dict
    }

}
