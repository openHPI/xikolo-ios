//
//  Collection+SafeSubscript.swift
//  xikolo-ios
//
//  Created by Max Bothe on 27.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}
