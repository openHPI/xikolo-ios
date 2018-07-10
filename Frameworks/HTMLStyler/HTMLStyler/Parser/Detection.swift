//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

struct Detection {
    let type: Tag
    let range: Range<String.Index>
    var isLastSibling: Bool

    init(type: Tag, range: Range<String.Index>) {
        self.type = type
        self.range = range
        self.isLastSibling = false
    }
}
