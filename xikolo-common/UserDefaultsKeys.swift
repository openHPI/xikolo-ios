//
//  UserDefaultsKeys.swift
//  xikolo-ios
//
//  Created by Max Bothe on 26.07.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {

    // negative form to have content preload activated by default
    // since UserDefault will return `false` if no value for the key is present
    static let noContentPreloadKey = "de.xikolo.ios.content.noPreload"

    static let playbackRateKey = "de.xikolo.ios.video.playbackRate"

    enum UserProfileKey : String {
        case user = "user"
        case token = "user_token"
        case welcome = "show_welcome_screen"
    }

}
