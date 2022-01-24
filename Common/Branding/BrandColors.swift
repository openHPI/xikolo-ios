//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

public struct BrandColors: Decodable {

    enum WindowColorChoice: String {
        case primary
        case secondary
        case tertiary
    }

    private enum CodingKeys: CodingKey {
        case window
    }

    private let windowColorChoice: WindowColorChoice

    public var primary: UIColor {
        return UIColor(named: "primary")!
    }

    public var secondary: UIColor {
        return UIColor(named: "secondary")!
    }

    public var tertiary: UIColor {
        return UIColor(named: "tertiary")!
    }

    public var primaryLight: UIColor {
        // Light mode: 25% over #FFFFFF - Dark Mode: 25% over #1D1D1E
        return UIColor(named: "primaryLight")!
    }

    public let answerCorrect = UIColor(red: 140 / 255, green: 179 / 255, blue: 13 / 255, alpha: 1)
    public let answerIncorrect = UIColor(red: 214 / 255, green: 0 / 255, blue: 26 / 255, alpha: 1)
    public let answerWrong = UIColor(red: 187 / 255, green: 188 / 255, blue: 190 / 255, alpha: 1)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.windowColorChoice = try container.decodeWindowColorChoice(forKey: .window)
    }

    public var window: UIColor {
        switch self.windowColorChoice {
        case .primary:
            return self.primary
        case .secondary:
            return self.secondary
        case .tertiary:
            return self.tertiary
        }
    }

}

private extension KeyedDecodingContainer {

    func decodeColor(forKey key: K) throws -> UIColor {
        let value = try self.decode(String.self, forKey: key)
        return UIColor(hexString: value)
    }

    func decodeWindowColorChoice(forKey key: K) throws -> BrandColors.WindowColorChoice {
        let value = try self.decode(String.self, forKey: key)
        return BrandColors.WindowColorChoice(rawValue: value) ?? .primary
    }

}
