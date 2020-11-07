//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

public enum Settings {

    public static func open() {
        guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(appSettings) else { return }
        UIApplication.shared.open(appSettings)
    }

}
