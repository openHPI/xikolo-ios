//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Marshal
import Stockpile

extension ResourceData {

    func failsafeURL(for key: KeyType) throws -> URL? {
        guard let urlString = try self.value(for: key) as String? else { return nil }
        let trimmedString = urlString.components(separatedBy: .whitespacesAndNewlines).joined()
        return URL(string: trimmedString)
    }

}
