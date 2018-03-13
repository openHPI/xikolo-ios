//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Down

extension NSAttributedString {

    /**
     Instantiates an attributed string with the given HTML string

     - parameter htmlString: An HTML string

     - throws: `HTMLDataConversionError` or an instantiation error

     - returns: An attributed string
     */
    convenience init(htmlString: String) throws {
        guard let data = htmlString.data(using: String.Encoding.utf8) else {
            throw DownErrors.htmlDataConversionError
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue),
        ]
        try self.init(data: data, options: options, documentAttributes: nil)
    }

}
