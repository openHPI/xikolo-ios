//
//  CustomUserDefaults.swift
//  xikolo-ios
//
//  Created by Max Bothe on 18.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

extension UserDefaults {

    private static let videoDownloadQualityKey = "de.xikolo.ios.video.download.quality"

    var videoPersistenceQuality: VideoPersistenceQuality {
        get {
            let rawValue = self.integer(forKey: UserDefaults.videoDownloadQualityKey)
            guard let value = VideoPersistenceQuality(rawValue: rawValue) else { return .low }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaults.videoDownloadQualityKey)
        }
    }

}
