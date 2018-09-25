//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

final class QuizOption: NSObject, NSCoding, IncludedPullable {

    var id: String
    var text: String?
    var position: Int32
    var correct: Bool
    var explanation: String?

    required init(object: ResourceData) throws {
        self.id = try object.value(for: "id")
        self.text = try object.value(for: "text")
        self.position = try object.value(for: "position")
        self.correct = try object.value(for: "correct")
        self.explanation = try object.value(for: "explanation")
    }

    required init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(forKey: "id") as? String else {
            return nil
        }

        self.id = id
        self.text = decoder.decodeObject(forKey: "text") as? String
        self.position = decoder.decodeInt32(forKey: "position")
        self.correct = decoder.decodeBool(forKey: "correct")
        self.explanation = decoder.decodeObject(forKey: "explanation") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.text, forKey: "text")
        coder.encode(self.position, forKey: "position")
        coder.encode(self.correct, forKey: "correct")
        coder.encode(self.explanation, forKey: "explanation")
    }

}
