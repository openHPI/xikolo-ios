//
//  CollectionType+dict.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

extension CollectionType {

    func toDictionary<K, V>(transform: (element: Self.Generator.Element) -> (K, V)?) -> [K:V] {
        var dictionary = [K:V]()
        for e in self {
            if let (key, value) = transform(element: e) {
                dictionary[key] = value
            }
        }
        return dictionary
    }

}
