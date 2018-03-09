//
//  UserDefaults+videoQuality.swift
//  xikolo-ios
//
//  Created by Max Bothe on 18.08.17.
//  Copyright © 2017 HPI. All rights reserved.
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
            return NSLocalizedString("settings.video-persistence-quality.low", comment: "low video persistence quality")
        case .medium:
            return NSLocalizedString("settings.video-persistence-quality.medium", comment: "medium video persistence quality")
        case .high:
            return NSLocalizedString("settings.video-persistence-quality.high", comment: "high video persistence quality")
        case .best:
            return NSLocalizedString("settings.video-persistence-quality.best", comment: "best video persistence quality")
        }
    }

}

extension UserDefaults {

    private static let videoQualityDownloadKey = "de.xikolo.ios.video.download.quality"

    var videoQualityForDownload: VideoQuality {
        get {
            let rawValue = self.integer(forKey: UserDefaults.videoQualityDownloadKey)
            guard let value = VideoQuality(rawValue: rawValue) else { return .low }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaults.videoQualityDownloadKey)
        }
    }

}

extension UserDefaults {

    private static let videoQualityCellularKey = "de.xikolo.ios.video.cellular.quality"

    var videoQualityOnCelluar: VideoQuality {
        get {
            let rawValue = self.integer(forKey: UserDefaults.videoQualityCellularKey)
            guard let value = VideoQuality(rawValue: rawValue) else { return .high }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaults.videoQualityCellularKey)
        }
    }

}

extension UserDefaults {

    private static let videoQualityWifiKey = "de.xikolo.ios.video.wifi.quality"

    var videoQualityOnWifi: VideoQuality {
        get {
            let rawValue = self.integer(forKey: UserDefaults.videoQualityWifiKey)
            guard let value = VideoQuality(rawValue: rawValue) else { return .high }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaults.videoQualityWifiKey)
        }
    }

}
