//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

public struct BrandColors: Decodable {

    private enum CodingKeys: CodingKey {
        case primary
        case secondary
        case tertiary
    }

    public let primary: UIColor
    public let secondary: UIColor
    public let tertiary: UIColor

    public let answerCorrect = UIColor(red: 140 / 255, green: 179 / 255, blue: 13 / 255, alpha: 1)
    public let answerIncorrect = UIColor(red: 214 / 255, green: 0 / 255, blue: 26 / 255, alpha: 1)
    public let answerWrong = UIColor(red: 187 / 255, green: 188 / 255, blue: 190 / 255, alpha: 1)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.primary = try container.decodeColor(forKey: .primary)
        self.secondary = try container.decodeColor(forKey: .secondary)
        self.tertiary = try container.decodeColor(forKey: .tertiary)
    }

    public var window: UIColor {
        return self.primary
    }

}

private extension KeyedDecodingContainer {

    func decodeColor(forKey key: K) throws -> UIColor {
        let value = try self.decode(String.self, forKey: key)
        return UIColor(hexString: value)
    }

}
