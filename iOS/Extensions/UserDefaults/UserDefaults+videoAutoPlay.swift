//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension UserDefaults {

    private static let videoAutoPlayDisableKey = "de.xikolo.ios.video.autoplay.disable"

    var disableVideoAutoPlay: Bool {
        get {
            return self.bool(forKey: Self.videoAutoPlayDisableKey)
        }
        set {
            self.set(newValue, forKey: Self.videoAutoPlayDisableKey)
        }
    }

}
