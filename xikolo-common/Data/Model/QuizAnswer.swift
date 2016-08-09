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
        if let value = dict["id"] as? String {
            id = value
        }
        if let value = dict["text"] as? String {
            text = value
        }
        if let value = dict["position"] as? NSNumber {
            position = value
        }
    }

    required init(coder decoder: NSCoder) {
        if let value = decoder.decodeObjectForKey("id") as? String {
            id = value
        }
        if let value = decoder.decodeObjectForKey("text") as? String {
            text = value
        }
        if let value = decoder.decodeObjectForKey("position") as? NSNumber {
            position = value
        }
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(text, forKey: "text")
        coder.encodeObject(position, forKey: "position")
    }

}
