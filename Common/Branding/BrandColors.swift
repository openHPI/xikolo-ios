//
//  Created for xikolo-ios under MIT license.
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
        case primary
        case secondary
        case tertiary
        case primaryLight
        case window
    }

    private let windowColorChoice: WindowColorChoice

    private let primaryFallback: UIColor
    private let secondaryFallback: UIColor
    private let tertiaryFallback: UIColor

    // Light mode: 30% over #FFFFFF - Dark Mode: 55% over #1D1D1E
    private let primaryLightFallback: UIColor

    public var primary: UIColor {
        if #available(iOS 13, *) {
            return UIColor(named: "primary") ?? self.primaryFallback
        } else {
            return self.primaryFallback
        }
    }

    public var secondary: UIColor {
        if #available(iOS 13, *) {
            return UIColor(named: "secondary") ?? self.secondaryFallback
        } else {
            return self.secondaryFallback
        }
    }

    public var tertiary: UIColor {
        if #available(iOS 13, *) {
            return UIColor(named: "tertiary") ?? self.tertiaryFallback
        } else {
            return self.tertiaryFallback
        }
    }

    public var primaryLight: UIColor {
        if #available(iOS 13, *) {
            return UIColor(named: "primaryLight") ?? self.primaryLightFallback
        } else {
            return self.primaryLightFallback
        }
    }

    public let answerCorrect = UIColor(red: 140 / 255, green: 179 / 255, blue: 13 / 255, alpha: 1)
    public let answerIncorrect = UIColor(red: 214 / 255, green: 0 / 255, blue: 26 / 255, alpha: 1)
    public let answerWrong = UIColor(red: 187 / 255, green: 188 / 255, blue: 190 / 255, alpha: 1)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.primaryFallback = try container.decodeColor(forKey: .primary)
        self.secondaryFallback = try container.decodeColor(forKey: .secondary)
        self.tertiaryFallback = try container.decodeColor(forKey: .tertiary)
        self.primaryLightFallback = try container.decodeColor(forKey: .primaryLight)
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
