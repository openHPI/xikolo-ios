//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Collection {

    func toDictionary<K, V>(_ transform: (_ element: Self.Iterator.Element) -> (K, V)?) -> [K: V] {
        var dictionary = [K: V]()
        for e in self {
            if let (key, value) = transform(e) {
                dictionary[key] = value
            }
        }
        return dictionary
    }

}
