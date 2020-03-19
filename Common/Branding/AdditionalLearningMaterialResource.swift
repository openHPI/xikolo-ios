//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct AdditionalLearningMaterialResource: Decodable {

    private enum CodingKeys: CodingKey {
        case type
        case url
    }

    public let type: AdditionalLearningMaterialResourceType
    public let url: URL

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(AdditionalLearningMaterialResourceType.self, forKey: .type)
        self.url = try container.decodeURL(forKey: .url)
    }

}

public enum AdditionalLearningMaterialResourceType: String, Decodable {
    case microLearning
    case podcasts

    public var displayName: String {
        switch self {
        case .microLearning:
            return CommonLocalizedString("additional-learning-material-resources.micro-learning.title",
                                         comment: "Display name for additional learning material resourse: micro learning")
        case .podcasts:
            return CommonLocalizedString("additional-learning-material-resources.podcasts.title",
                                         comment: "Display name for additional learning material resourse: podcasts")
        }
    }

}
