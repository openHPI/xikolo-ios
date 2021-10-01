//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension String {

    public func safeAsciiString() -> String? {
        let charSubstitutions = [
            "Ä": "Ae",
            "ä": "ae",
            "Ö": "Oe",
            "ö": "oe",
            "Ü": "Ue",
            "ü": "ue",
            "ß": "ss",
        ]

        var asciiText = self
        for (char, substitution) in charSubstitutions {
            asciiText = asciiText.replacingOccurrences(of: char, with: substitution)
        }

        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.formUnion(CharacterSet.whitespaces)
        allowedCharacters.formUnion(CharacterSet.punctuationCharacters)

        return asciiText.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

}
