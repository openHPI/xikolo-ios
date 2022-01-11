//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

struct URLDropRepresentation: Encodable {

    let url: URL
    let title: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.url.absoluteString)
        try container.encode("")
        try container.encode(self.metadata)
    }

    private var metadata: [String: String] {
        guard let title = self.title else {
            return [:]
        }

        return ["title": title]
    }

}
