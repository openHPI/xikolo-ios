//
//  BingeLocalizedString.swift
//  Binge
//
//  Created by Max Bothe on 14.02.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import Foundation

class BingeLocalizer {

    static func localizedString(_ key: String, comment: String) -> String {
        let bundle = Bundle(for: BingeLocalizer.self)
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }

}

func BingeLocalizedString(_ key: String, comment: String) -> String {
    return BingeLocalizer.localizedString(key, comment: comment)
}
