//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension UserDefaults {

    private static let playbackRateKey = "de.xikolo.ios.video.playbackRate"

    var playbackRate: Float {
        get {
            return self.float(forKey: UserDefaults.playbackRateKey)
        }
        set {
            self.set(newValue, forKey: UserDefaults.playbackRateKey)
        }
    }

}
