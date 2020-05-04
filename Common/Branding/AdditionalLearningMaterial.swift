//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct AdditionalLearningMaterial: Decodable {

    private enum CodingKeys: CodingKey {
        case title
        case url
        case imageName
    }

    public let title: String
    public let url: URL
    public let imageName: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decodeURL(forKey: .url)
        self.imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
    }

}

private extension KeyedDecodingContainer {

    func decodeURL(forKey key: K) throws -> URL {
        let value = try self.decode(String.self, forKey: key)
        return URL(string: value)!
    }

}
