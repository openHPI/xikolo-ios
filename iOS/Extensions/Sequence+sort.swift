//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { item1, item2 in
            return item1[keyPath: keyPath] < item2[keyPath: keyPath]
        }
    }
}
