//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import Binge
import Common

extension BingePlayerViewController {

    func configure(for video: Video) {
        if let offlinePlayableAsset = StreamPersistenceManager.shared.offlinePlayableAsset(for: video) {
            self.asset = offlinePlayableAsset
        } else if let fallbackURL = video.streamURLForDownload ?? video.singleStream?.hdURL ?? video.singleStream?.sdURL {
            self.asset = AVURLAsset(url: fallbackURL)
        }

        self.assetTitle = video.item?.title
        self.assetSubtitle = video.item?.section?.course?.title
    }

}
