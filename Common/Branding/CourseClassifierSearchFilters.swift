//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct CourseClassifierSearchFilters: Decodable {
    public let category: CourseClassifierSearchFilterType?
    public let topic: CourseClassifierSearchFilterType?
}

public enum CourseClassifierSearchFilterType: String, Decodable {
    case targetAudience
    case proficiencyLevel
    case topic

    public var displayName: String {
        switch self {
        case .targetAudience:
            return CommonLocalizedString("course-list.search.filter.title.target audience", comment: "Title for target audience filter (sap)")
        case .proficiencyLevel:
            return CommonLocalizedString("course-list.search.filter.title.proficiency level", comment: "Title for proficiency level filter (who)")
        case .topic:
            return CommonLocalizedString("course-list.search.filter.title.topic", comment: "Title for topic filter (hpi + sap)")
        }
    }
}
