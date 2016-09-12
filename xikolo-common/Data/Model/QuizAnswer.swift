//
//  QuizAnswer.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 09.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class QuizAnswer : NSObject, NSCoding, EmbeddedObject {

    var id: String?
    var text: String?
    var position: NSNumber?

    required init(_ dict: [String : AnyObject]) {
        id = dict["id"] as? String
        text = dict["text"] as? String
        position = dict["position"] as? NSNumber
    }

    required init(coder decoder: NSCoder) {
        id = decoder.decodeObjectForKey("id") as? String
        text = decoder.decodeObjectForKey("text") as? String
        position = decoder.decodeObjectForKey("position") as? NSNumber
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(text, forKey: "text")
        coder.encodeObject(position, forKey: "position")
    }

}
