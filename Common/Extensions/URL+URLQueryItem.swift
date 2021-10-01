//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension URL {

    public func appendingPathComponents(_ components: [String]) -> URL {
        var url = self

        for component in components {
            url = url.appendingPathComponent(component)
        }

        return url
    }

}
