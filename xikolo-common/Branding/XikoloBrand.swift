//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

//protocol XikoloBrand {
//
//    static var host: String { get }
//    static var imprintURL: URL { get }
//    static var privacyURL: URL { get }
//
//    static var platformTitle: String { get }
//    static var singleSignOnButtonTitle: String? { get }
//
//    static var copyrightName: String { get }
//    static var poweredByText: String? { get }
//
//}
//
//extension XikoloBrand {
//
//    static var singleSignOnButtonTitle: String? {
//        return nil
//    }
//
//    static var copyrightText: String {
//        let currentYear = Calendar.current.component(.year, from: Date())
//        return "Copyright © \(currentYear) \(Self.copyrightName). All rights reserved."
//    }
//
//    static var poweredByText: String? {
//        return nil
//    }
//
//    static var locale: Locale {
//        if Bundle.main.localizations.contains(Locale.current.languageCode ?? Locale.current.identifier) {
//            return Locale.current
//        } else {
//            return Locale(identifier: "en")
//        }
//    }
//
//    static var feedbackRecipients: [String] {
//        return ["mobile-feedback@hpi.de"]
//    }
//
//    static var feedbackSubject: String {
//        return "\(UIApplication.appName) | App Feedback"
//    }
//
//}

public struct Brand: Decodable {

    private enum CodingKeys: CodingKey {
        case host
        case imprintURL
        case privacyURL
        case platformTitle
        case singleSignOnButtonTitle
        case copyrightName
        case poweredByText
        case colors
    }

    public static let `default`: Brand = {
        let data = NSDataAsset(name: "BrandConfiguration")?.data
        let data2 = data.require(hint: "No brand configuration found")
        let decoder = PropertyListDecoder()
        return try! decoder.decode(Brand.self, from: data2)
    }()

    public let host: String
    public let imprintURL: URL
    public let privacyURL: URL

    public let platformTitle: String
    public var singleSignOnButtonTitle: String?

    public let copyrightName: String
    public var poweredByText: String?

    public let colors: BrandColors

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decode(String.self, forKey: .host)
        self.imprintURL = try container.decodeURL(forKey: .imprintURL)
        self.privacyURL = try container.decodeURL(forKey: .privacyURL)
        self.platformTitle = try container.decode(String.self, forKey: .platformTitle)
        self.singleSignOnButtonTitle = try container.decodeIfPresent(String.self, forKey: .singleSignOnButtonTitle)
        self.copyrightName = try container.decode(String.self, forKey: .copyrightName)
        self.poweredByText = try container.decodeIfPresent(String.self, forKey: .poweredByText)
        self.colors = try container.decode(BrandColors.self, forKey: .colors)
    }

    public var copyrightText: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "Copyright © \(currentYear) \(self.copyrightName). All rights reserved."
    }

    public var locale: Locale {
        if Bundle.main.localizations.contains(Locale.current.languageCode ?? Locale.current.identifier) {
            return Locale.current
        } else {
            return Locale(identifier: "en")
        }
    }

    public var feedbackRecipients: [String] {
        return ["mobile-feedback@hpi.de"]
    }

    public var feedbackSubject: String {
        return "\(UIApplication.appName) | App Feedback"
    }

}

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

    func decodeURL(forKey key: K) throws -> URL {
        let value = try self.decode(String.self, forKey: key)
        return URL(string: value)!
    }

    func decodeColor(forKey key: K) throws -> UIColor {
        let value = try self.decode(String.self, forKey: key)
        return UIColor(hexString: value)
    }

}
