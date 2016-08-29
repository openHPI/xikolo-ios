//
//  TrackingEventVerb.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class TrackingEventVerb : NSObject, EmbeddedObject {

    var type: String?

    required init(_ dict: [String : AnyObject]) {
        if let type = dict["type"] as? String {
            self.type = type
        }
    }

    override init() {
    }

    func toDict() -> [String : AnyObject] {
        var dict = [String: AnyObject]()
        if let type = type {
            dict["type"] = type
        }
        return dict
    }

}
