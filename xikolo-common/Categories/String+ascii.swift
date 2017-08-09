//
//  String+ascii.swift
//  openHPI-iOS
//
//  Created by Max Bothe on 09.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

extension String {

    func safeAsciiString() -> String? {
        let charSubstitions = [
            "Ä" : "Ae",
            "ä" : "ae",
            "Ö" : "Oe",
            "ö" : "oe",
            "Ü" : "Ue",
            "ü" : "ue",
            "ß" : "ss",
        ]

        var asciiText = self
        for (char, substitution) in charSubstitions {
            asciiText = asciiText.replacingOccurrences(of: char, with: substitution)
        }

        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.formUnion(CharacterSet.whitespaces)
        allowedCharacters.formUnion(CharacterSet.punctuationCharacters)

        return asciiText.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

}
