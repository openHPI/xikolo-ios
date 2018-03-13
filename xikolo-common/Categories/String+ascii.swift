//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension String {

    func safeAsciiString() -> String? {
        let charSubstitions = [
            "Ä": "Ae",
            "ä": "ae",
            "Ö": "Oe",
            "ö": "oe",
            "Ü": "Ue",
            "ü": "ue",
            "ß": "ss",
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
