//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIImage {

    static func appIcon(withPreferredWidth appIconWidth: Int) -> UIImage? {
        guard let iconsDictionary = Bundle.appBundle.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String] else {
            return nil
        }

        guard let iconName = iconFiles.first(where: { $0.hasSuffix("\(appIconWidth)x\(appIconWidth)") }) ?? iconFiles.last else {
            return nil
        }

        return UIImage(named: iconName, in: Bundle.appBundle, with: nil)
    }

}
