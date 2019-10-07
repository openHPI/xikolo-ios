//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BMPlayer

class CustomBMPlayer: BMPlayer {

    weak var videoController: VideoViewController?

    override func seek(_ to: TimeInterval, completion: (() -> Void)? = nil) { // swiftlint:disable:this identifier_name
        let from = self.playerLayer?.player?.currentTime().seconds
        super.seek(to, completion: completion)
        self.videoController?.trackVideoSeek(from: from, to: to)
    }

}
