//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class QuizQuestionOption: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

    public var id: String
    public var text: String?
    public var position: Int32
    public var correct: Bool
    public var explanation: String?

    required public init(object: ResourceData) throws {
        self.id = try object.value(for: "id")
        self.text = try object.value(for: "text")
        self.position = try object.value(for: "position")
        self.correct = try object.value(for: "correct")
        self.explanation = try object.value(for: "explanation")
    }

    required public init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObject(of: NSString.self, forKey: "id") as String? else {
            return nil
        }

        self.id = id
        self.text = decoder.decodeObject(of: NSString.self, forKey: "text") as String?
        self.position = decoder.decodeInt32(forKey: "position")
        self.correct = decoder.decodeBool(forKey: "correct")
        self.explanation = decoder.decodeObject(of: NSString.self, forKey: "explanation") as String?
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.text, forKey: "text")
        coder.encode(self.position, forKey: "position")
        coder.encode(self.correct, forKey: "correct")
        coder.encode(self.explanation, forKey: "explanation")
    }

}
