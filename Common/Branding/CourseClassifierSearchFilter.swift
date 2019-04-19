//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct CourseClassifierSearchFilter: Decodable {
    public let category: CourseClassifierSearchFilterType?
    public let topic: CourseClassifierSearchFilterType?
}

public enum CourseClassifierSearchFilterType: String, Decodable {
    case track
    case targetAudience
    case proficiencyLevel
    case topic

    public var displayName: String {
        switch self {
        case .track:
            return CommonLocalizedString("course-list.search.filter.title.track", comment: "Title for track filter (hpi)")
        case .targetAudience:
            return CommonLocalizedString("course-list.search.filter.title.target audience", comment: "Title for target audience filter (sap)")
        case .proficiencyLevel:
            return CommonLocalizedString("course-list.search.filter.title.proficiency level", comment: "Title for proficiency level filter (who)")
        case .topic:
            return CommonLocalizedString("course-list.search.filter.title.topic", comment: "Title for topic filter (sap)")
        }
    }
}
