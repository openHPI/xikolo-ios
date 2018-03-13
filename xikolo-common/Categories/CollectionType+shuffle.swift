//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int, IndexDistance == Int {

    mutating func shuffleInPlace() {
        if count < 2 {
            return
        }

        for i in 0 ..< count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else {
                continue
            }

            swap(&self[i], &self[j])
        }
    }

}

extension Collection {

    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }

}
