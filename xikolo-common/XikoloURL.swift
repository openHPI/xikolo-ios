//
//  XikoloURI.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 27.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class XikoloURL {

    var type: XikoloURLTypes
    var targetId: String

    init(type: XikoloURLTypes, targetId: String) {
        self.type = type
        self.targetId = targetId
    }

    func toURL() -> NSURL {
        let components = NSURLComponents()
        components.scheme = "xikolo-tvos"

        switch(type) {
        case .Course:
            components.path = "course/\(targetId)"
        }
        return components.URL!
    }

    class func parseURL(url: NSURL) -> XikoloURL? {
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
            if components.scheme != "xikolo-tvos" {
                return nil
            }

            let pathComponents = components.path?.componentsSeparatedByString("/")
            if pathComponents?.isEmpty ?? true {
                return nil
            }

            let type = pathComponents![0]
            switch type {
            case "course":
                if pathComponents!.count != 2 {
                    return nil
                }
                return XikoloURL(type: .Course, targetId: pathComponents![1])
            default:
                return nil
            }
        }
        return nil
    }

}

enum XikoloURLTypes {

    case Course;

}
