//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

public struct Brand: Decodable {

    private enum CodingKeys: CodingKey {
        case host
        case imprintURL
        case privacyURL
        case faqURL
        case singleSignOn
        case copyrightName
        case poweredByText
        case colors
        case courseDateLabelStyle
        case showCurrentCoursesInSelfPacedSection
        case features
        case courseClassifierSearchFilters
        case additionalLearningMaterial
        case testAccountUserId
    }

    public static let `default`: Brand = {
        let data = NSDataAsset(name: "BrandConfiguration")?.data
        let decoder = PropertyListDecoder()
        return try! decoder.decode(Brand.self, from: data!) // swiftlint:disable:this force_try
    }()

    private let copyrightName: String

    public let host: String
    let imprintURL: URL
    let privacyURL: URL
    let faqURL: URL

    public let colors: BrandColors
    public let singleSignOn: SingleSignOnConfiguration?
    public let poweredByText: String?
    public let courseDateLabelStyle: CourseDateLabelStyle
    public let showCurrentCoursesInSelfPacedSection: Bool
    public let features: BrandFeatures
    public let courseClassifierSearchFilters: CourseClassifierSearchFilters?
    public let additionalLearningMaterial: [AdditionalLearningMaterial]
    public let testAccountUserId: String?

    public var copyrightText: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "Copyright © \(currentYear) \(self.copyrightName). All rights reserved."
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decode(String.self, forKey: .host)
        self.imprintURL = try container.decodeURL(forKey: .imprintURL)
        self.privacyURL = try container.decodeURL(forKey: .privacyURL)
        self.faqURL = try container.decodeURL(forKey: .faqURL)
        self.singleSignOn = try? container.decode(SingleSignOnConfiguration.self, forKey: .singleSignOn)
        self.copyrightName = try container.decode(String.self, forKey: .copyrightName)
        self.poweredByText = try container.decodeIfPresent(String.self, forKey: .poweredByText)
        self.colors = try container.decode(BrandColors.self, forKey: .colors)
        self.courseDateLabelStyle = try container.decodeCourseDateLabelStyle(forKey: .courseDateLabelStyle)
        self.showCurrentCoursesInSelfPacedSection = try container.decodeIfPresent(Bool.self, forKey: .showCurrentCoursesInSelfPacedSection) ?? false
        self.features = try container.decode(BrandFeatures.self, forKey: .features)
        self.courseClassifierSearchFilters = try? container.decode(CourseClassifierSearchFilters.self, forKey: .courseClassifierSearchFilters)
        self.additionalLearningMaterial = try container.decodeIfPresent([AdditionalLearningMaterial].self, forKey: .additionalLearningMaterial) ?? []
        self.testAccountUserId = try? container.decode(String.self, forKey: .testAccountUserId)
    }

}

private extension KeyedDecodingContainer {

    func decodeURL(forKey key: K) throws -> URL {
        let value = try self.decode(String.self, forKey: key)
        return URL(string: value)!
    }

    func decodeCourseDateLabelStyle(forKey key: K) throws -> CourseDateLabelStyle {
        let defaultValue = CourseDateLabelStyle.normal
        guard let value = try self.decodeIfPresent(String.self, forKey: key) else { return defaultValue }
        return CourseDateLabelStyle(rawValue: value) ?? defaultValue
    }

}
