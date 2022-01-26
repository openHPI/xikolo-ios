//
//  Created for xikolo-ios under GPL-3.0 license.
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

        if UserDefaults.standard.playbackRate > 0 {
            self.playbackRate = UserDefaults.standard.playbackRate
        }

        if video.lastPosition > 0 {
            self.startPosition = video.lastPosition
        }

        if let offlinePlayableAsset = self.offlinePlayableAsset(for: video) {
            self.asset = offlinePlayableAsset
        } else if let fallbackURL = video.streamURLForDownload ?? video.singleStream?.hdURL ?? video.singleStream?.sdURL {
            self.asset = AVURLAsset(url: fallbackURL)
        } else {
            self.asset = nil
        }

        if let posterImageURL = video.item?.section?.course?.imageURL {
            DispatchQueue.main.async {
                if let imageData = try? Data(contentsOf: posterImageURL), let image = UIImage(data: imageData) {
                    self.posterImage = image
                }
            }
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
        let videoQuality = ReachabilityHelper.connection == .wifi ? UserDefaults.standard.videoQualityOnWifi : UserDefaults.standard.videoQualityOnCellular
        return Double(videoQuality.rawValue)
    }

}
