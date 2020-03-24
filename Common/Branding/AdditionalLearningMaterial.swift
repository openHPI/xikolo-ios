//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct AdditionalLearningMaterial: Decodable {

    private enum CodingKeys: CodingKey {
        case type
        case url
    }

    public let type: AdditionalLearningMaterialType
    public let url: URL

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(AdditionalLearningMaterialType.self, forKey: .type)
        self.url = try container.decodeURL(forKey: .url)
    }

}

public enum AdditionalLearningMaterialType: String, Decodable {
    case microLearning
    case podcasts

    public var displayName: String {
        switch self {
        case .microLearning:
            return CommonLocalizedString("additional-learning-material.micro-learning.title",
                                         comment: "Display name for additional learning material: micro learning")
        case .podcasts:
            return CommonLocalizedString("additional-learning-material.podcasts.title",
                                         comment: "Display name for additional learning material: podcasts")
        }
    }

}

private extension KeyedDecodingContainer {

    func decodeURL(forKey key: K) throws -> URL {
        let value = try self.decode(String.self, forKey: key)
        return URL(string: value)!
    }

}
