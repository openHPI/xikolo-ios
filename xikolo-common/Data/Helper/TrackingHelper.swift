//
//  TrackingHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import UIKit

class TrackingHelper {

    #if os(tvOS)
    fileprivate static let platform = "tvOS"
    #else
    fileprivate static let platform = "iOS"
    #endif

    fileprivate static let osVersion: String = {
        let version = ProcessInfo().operatingSystemVersion
        return version.toString()
    }()

    fileprivate static let device: String = {
        var sysinfo = utsname()
        uname(&sysinfo)
        var name = withUnsafeMutablePointer(to: &sysinfo.machine) { ptr in
            String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        if ["i386", "x86_64"].contains(name) {
            name = "Simulator"
        }
        return name
    }()

    fileprivate class func defaultContext() -> [String: String] {
        let bundleInfo = Bundle.main.infoDictionary!

        let screenSize = UIScreen.main.bounds.size

        return [
            "platform": platform,
            "platform_version": osVersion,
            "runtime": platform,
            "runtime_version": osVersion,
            "device": device,
            "build_version_name": bundleInfo["CFBundleShortVersionString"] as! String,
            "build_number": bundleInfo["CFBundleVersion"] as! String,
            "screen_width": String(Int(screenSize.width)),
            "screen_height": String(Int(screenSize.height)),
        ]
    }

    fileprivate class func createEvent(_ verb: String, resource: BaseModel?, context: [String: String?] = [:]) -> Future<TrackingEvent, XikoloError> {

        let trackingVerb = TrackingEventVerb()
        trackingVerb.type = verb

        var trackingContext = defaultContext()

        for (k, v) in context {
            if let v = v {
                trackingContext.updateValue(v, forKey: k)
            }
        }

        let trackingEvent = TrackingEvent()
        let trackingUser = TrackingEventUser()
        trackingUser.uuid = UserProfileHelper.getUserId()
        trackingEvent.user = trackingUser
        trackingEvent.verb = trackingVerb
        if let resource = resource {
            trackingEvent.resource = TrackingEventResource(resource: resource)
        } else {
            //this is a fallback required by the tracking API where ressource cant be empty
            trackingEvent.resource = TrackingEventResource(type: "None")
        }
        trackingEvent.timestamp = Date()
        trackingEvent.context = trackingContext as [String : AnyObject]?
        return Future.init(value: trackingEvent)
    }

    @discardableResult class func sendEvent(_ verb: String, resource: BaseModel?, context: [String: String?] = [:]) -> Future<Void, XikoloError> {
        return createEvent(verb, resource: resource, context: context).flatMap { event -> Future<Void, XikoloError> in
            SpineHelper.save(event).asVoid()
        }
    }

}
