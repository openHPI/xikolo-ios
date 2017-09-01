//
//  Settings.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class Settings {

    class func open() {
        guard let appSettings = URL(string: UIApplicationOpenSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(appSettings) else { return }
        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        // TODO: write test for this
    }

}
