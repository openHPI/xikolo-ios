//
//  String+regex.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 15.05.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

extension String {
    mutating func stringByRemovingRegexMatches(pattern: String, replaceWith: String = "") -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.characters.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return nil
        }
    }
}
