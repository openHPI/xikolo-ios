//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
enum ActivityIdentifier: String {
    case openCourse = "com.xikolo.openCourse"

    func sceneConfiguration() -> UISceneConfiguration {
        switch self {
        case .openCourse:
            return UISceneConfiguration(
                name: SceneConfigurationNames.openCourse,
                sessionRole: .windowApplication
            )
        }
    }

}
