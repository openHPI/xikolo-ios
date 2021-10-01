//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import UIKit

class BingePlayerView: UIView {

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer // swiftlint:disable:this force_cast
    }

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
        }
    }

}
