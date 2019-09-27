//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

enum VideoQuality: Int, CustomStringConvertible {
    case low = 200000
    case medium = 400000
    case high = 5000000
    case best = 10000000

    static var orderedValues: [VideoQuality] {
        return [.low, .medium, .high, .best]
    }

    var description: String {
        switch self {
        case .low:
            return NSLocalizedString("settings.video-quality.low", comment: "low video quality")
        case .medium:
            return NSLocalizedString("settings.video-quality.medium", comment: "medium video quality")
        case .high:
            return NSLocalizedString("settings.video-quality.high", comment: "high video quality")
        case .best:
            return NSLocalizedString("settings.video-quality.best", comment: "best video quality")
        }
    }

}

extension UserDefaults {

    private static let videoQualityDownloadKey = "de.xikolo.ios.video.download.quality"

    var videoQualityForDownload: VideoQuality {
        get {
            let rawValue = self.integer(forKey: Self.videoQualityDownloadKey)
            guard let value = VideoQuality(rawValue: rawValue) else { return .low }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: Self.videoQualityDownloadKey)
        }
    }

}

extension UserDefaults {

    private static let videoQualityCellularKey = "de.xikolo.ios.video.cellular.quality"

    var videoQualityOnCellular: VideoQuality {
        get {
            let rawValue = self.integer(forKey: Self.videoQualityCellularKey)
            guard let value = VideoQuality(rawValue: rawValue) else { return .high }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: Self.videoQualityCellularKey)
        }
    }

}

extension UserDefaults {

    private static let videoQualityWifiKey = "de.xikolo.ios.video.wifi.quality"

    var videoQualityOnWifi: VideoQuality {
        get {
            let rawValue = self.integer(forKey: Self.videoQualityWifiKey)
            guard let value = VideoQuality(rawValue: rawValue) else { return .high }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: Self.videoQualityWifiKey)
        }
    }

}
