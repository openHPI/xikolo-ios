//
//  QuizAnswer.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 09.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

@objcMembers
class QuizOption : NSObject, NSCoding, EmbeddedObject {

    var id: String?
    var text: String?
    var position: NSNumber?
    var correct: Bool?
    var explanation: String?

    required init(_ dict: [String : AnyObject]) {
        id = dict["id"] as? String
        text = dict["text"] as? String
        position = dict["position"] as? NSNumber
        correct = dict["correct"] as? Bool
        explanation = dict["explanation"] as? String
    }

    required init(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as? String
        text = decoder.decodeObject(forKey: "text") as? String
        position = decoder.decodeObject(forKey: "position") as? NSNumber
        correct = decoder.decodeObject(forKey: "correct") as? Bool
        explanation = decoder.decodeObject(forKey: "explanation") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(text, forKey: "text")
        coder.encode(position, forKey: "position")
        coder.encode(correct, forKey: "correct")
        coder.encode(explanation, forKey: "explanation")

    }

}
