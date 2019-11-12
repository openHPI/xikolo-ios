//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

public class HelpdeskTicket {

    public enum Topic {
        case technical
        case reactivation
        case courseSpecific(course: Course)

        var identifier: String {
            switch self {
            case .technical:
                return "technical"
            case .reactivation:
                return "reactivation"
            case .courseSpecific(_):
                return "course"
            }
        }
    }

    let title: String
    let email: String
    let report: String
    let topic: Topic
    //let language: String

    public init(title: String, email: String, topic: Topic, report: String) {
                //url: URL?, language : String
        self.title = title
        self.email = email
        self.report = report
        self.topic = topic
        //self.language = language
    }

    private var currentTrackingData: String {
        return "platform: \(UIApplication.platform), os version: \(UIApplication.osVersion), device: \(UIApplication.device) app name: \(UIApplication.appName), app version: \(UIApplication.appVersion), app build: \(UIApplication.appBuild)"
    }

}

extension HelpdeskTicket: JSONAPIPushable {

    public var objectStateValue: Int16 {
        get {
            return ObjectState.new.rawValue
        }
        set {} // swiftlint:disable:this unused_setter_value
    }

    public static var type: String {
        return "tickets"
    }
    
    //comuted property language
    public func resourceAttributes() -> [String : Any] {
        return [
            "title": self.title,
            "email": self.email,
            "report" : self.report,
            "topic": self.topic.identifier,
            "data": self.currentTrackingData,
            //"language": self.language
        ]
    }

    public func resourceRelationships() -> [String : AnyObject]? {
        if case let Topic.courseSpecific(course) = self.topic {
            return [ "course" : course as AnyObject ]
        }
        else { return nil }
    }

}
