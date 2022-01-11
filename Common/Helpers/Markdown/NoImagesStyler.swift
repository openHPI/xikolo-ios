//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Down

class NoImagesStyler: DownStyler {

    override func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        let range = NSRange(location: 0, length: str.length)
        str.replaceCharacters(in: range, with: "")
    }

}
