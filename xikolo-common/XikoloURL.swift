//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

class XikoloURL {

    var type: XikoloURLTypes
    var targetId: String

    init(type: XikoloURLTypes, targetId: String) {
        self.type = type
        self.targetId = targetId
    }

    func toURL() -> URL {
        var components = URLComponents()
        components.scheme = "xikolo-tvos"

        switch type {
        case .course:
            components.path = "course/\(targetId)"
        }

        return components.url!
    }

    class func parseURL(_ url: URL) -> XikoloURL? {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if components.scheme != "xikolo-tvos" {
                return nil
            }

            let pathComponents = components.path.components(separatedBy: "/")
            if pathComponents.isEmpty {
                return nil
            }

            let type = pathComponents[0]
            switch type {
            case "course":
                if pathComponents.count != 2 {
                    return nil
                }
            
                return XikoloURL(type: .course, targetId: pathComponents[1])
            default:
                return nil
            }
        }

        return nil
    }

}

enum XikoloURLTypes {

    case course

}
