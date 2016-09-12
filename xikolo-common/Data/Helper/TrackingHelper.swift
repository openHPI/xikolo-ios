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
    private static let platform = "tvOS"
    #else
    private static let platform = "iOS"
    #endif

    private static let osVersion: String = {
        let version = NSProcessInfo().operatingSystemVersion
        return version.toString()
    }()

    private static let device: String = {
        var sysinfo = utsname()
        uname(&sysinfo)
        var name = withUnsafeMutablePointer(&sysinfo.machine) { ptr in
            String.fromCString(UnsafePointer<CChar>(ptr))!
        }
        if ["i386", "x86_64"].contains(name) {
            name = "Simulator"
        }
        return name
    }()

    private class func defaultContext() -> [String: String] {
        let bundleInfo = NSBundle.mainBundle().infoDictionary!

        let screenSize = UIScreen.mainScreen().bounds.size

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

    private class func createEvent(verb: String, resource: BaseModel, context: [String: String]) -> Future<TrackingEvent, XikoloError> {
        guard let trackingResource = TrackingEventResource(resource: resource) else {
            return Future.init(error: XikoloError.ModelIncomplete)
        }

        let trackingVerb = TrackingEventVerb()
        trackingVerb.type = verb

        var trackingContext = defaultContext()
        for (k, v) in context {
            trackingContext.updateValue(v, forKey: k)
        }

        let trackingEvent = TrackingEvent()
        trackingEvent.verb = trackingVerb
        trackingEvent.resource = trackingResource
        trackingEvent.timestamp = NSDate()
        trackingEvent.context = trackingContext

        return UserProfileHelper.getUser().map { user in
            let trackingUser = TrackingEventUser()
            trackingUser.uuid = user.id
            trackingEvent.user = trackingUser

            return trackingEvent
        }
    }

    class func sendEvent(verb: String, resource: BaseModel, context: [String: String] = [:]) -> Future<Void, XikoloError> {
        return createEvent(verb, resource: resource, context: context).flatMap { event -> Future<Void, XikoloError> in
            SpineHelper.save(event).asVoid()
        }
    }

}
