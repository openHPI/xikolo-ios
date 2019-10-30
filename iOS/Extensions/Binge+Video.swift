//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import Binge
import Common

extension BingePlayerViewController {

    func configure(for video: Video) {
        self.initiallyShowControls = false
        self.assetTitle = video.item?.title
        self.assetSubtitle = video.item?.section?.course?.title
        self.preferredPeakBitRate = video.preferredPeakBitRate()

        if let offlinePlayableAsset = self.offlinePlayableAsset(for: video) {
            self.asset = offlinePlayableAsset
        } else if let fallbackURL = video.streamURLForDownload ?? video.singleStream?.hdURL ?? video.singleStream?.sdURL {
            self.asset = AVURLAsset(url: fallbackURL)
        }
    }

    private func offlinePlayableAsset(for video: Video) -> AVURLAsset? {
        guard let localFileLocation = StreamPersistenceManager.shared.localFileLocation(for: video) else { return nil }
        let asset = AVURLAsset(url: localFileLocation)
        return asset.assetCache?.isPlayableOffline == true ? asset : nil
    }

}

extension Video {

    func preferredPeakBitRate() -> Double? {
        guard StreamPersistenceManager.shared.localFileLocation(for: self) == nil else { return nil }
        let videoQuaility = ReachabilityHelper.connection == .wifi ? UserDefaults.standard.videoQualityOnWifi : UserDefaults.standard.videoQualityOnCellular
        return Double(videoQuaility.rawValue)
    }

}
