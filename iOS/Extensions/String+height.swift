//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension String {

    func height(forTextStyle style: UIFont.TextStyle, boundingWidth width: CGFloat) -> CGFloat {
        guard !self.isEmpty else { return 0 }

        let boundingSize = CGSize(width: width, height: CGFloat.infinity)
        let attributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: style)]
        let size = NSString(string: self).boundingRect(with: boundingSize,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: attributes,
                                                       context: nil)
        return ceil(size.height)
    }

}
