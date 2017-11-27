//
//  TrackingHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import UIKit

class TrackingHelper {

    enum AnalyticsKeys : String {
        // tabs
        case visitedDashboard = "VISITED_DASHBOARD"
        case visitedAnnouncementList = "VISITED_ANNOUNCEMENTS"
        case visitedActivityStream = "VISITED_ACTIVITY_STREAM"
        case visitedProfile = "VISITED_PROFILE"

        // subpages
        case visitedItem = "VISITED_ITEM"
        case visitedAnnouncement = "VISITED_ANNOUNCEMENT_DETAIL"

        // video playback
        case videoPlaybackPlay = "VIDEO_PLAY"
        case videoPlaybackPause = "VIDEO_PAUSE"
        case videoPlaybackSeek = "VIDEO_SEEK"
        case videoPlaybackEnd = "VIDEO_END"
        case videoPlaybackDeviceOrientationPortrait = "VIDEO_PORTRAIT"
        case videoPlaybackDeviceOrientationLandscape = "VIDEO_LANDSCAPE"
        case videoPlaybackChangeSpeed = "VIDEO_CHANGE_SPEED"

        // video download
        case videoDownloadStart = "DOWNLOADED_HLS_VIDEO"
        case videoDownloadFinished = "DOWNLOADED_HLS_VIDEO_FINISHED"
        case videoDownloadCanceled = "DOWNLOADED_HLS_VIDEO_CANCELED"
    }

    private class func defaultContext() -> [String: String] {
        let screenSize = UIScreen.main.bounds.size
        let windowSize = (UIApplication.shared.delegate as? AppDelegate)?.window?.frame.size

        return [
            "platform": UIApplication.platform,
            "platform_version": UIApplication.osVersion,
            "runtime": UIApplication.platform,
            "runtime_version": UIApplication.osVersion,
            "device": UIApplication.device,
            "build_version_name": UIApplication.appVersion,
            "build_version": UIApplication.appBuild,
            "screen_width": String(Int(screenSize.width)),
            "screen_height": String(Int(screenSize.height)),
            "window_width": String(Int(windowSize?.width ?? 0)),
            "window_height": String(Int(windowSize?.height ?? 0)),
            "client_id": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "free_space": String(describing: self.systemFreeSize),
            "total_space": String(describing: self.systemSize),
        ]
    }

    @discardableResult class func createEvent(_ verb: AnalyticsKeys, resource: ResourceRepresentable?, context: [String: String?] = [:]) -> Future<NSManagedObjectID, XikoloError> {
        guard let userId = UserProfileHelper.userId else {
            return Future(error: .trackingForUnknownUser)
        }

        let trackingUser = TrackingEventUser(uuid: userId)
        let trackingVerb = TrackingEventVerb(type: verb.rawValue)

        let trackingResource: TrackingEventResource
        if let resource = resource {
            trackingResource = TrackingEventResource(resource: resource)
        } else {
            trackingResource = TrackingEventResource.noneResource()
        }

        var trackingContext = self.defaultContext()
        for (k, v) in context {
            if let value = v {
                trackingContext.updateValue(value, forKey: k)
            }
        }

        let promise = Promise<NSManagedObjectID, XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let trackingEvent = TrackingEvent(user: trackingUser,
                                              verb: trackingVerb,
                                              resource: trackingResource,
                                              trackingContext: trackingContext as [String: AnyObject],
                                              inContext: context)
            do {
                try context.save()
                promise.success(trackingEvent.objectID)
            } catch {
                promise.failure(.coreData(error))
            }
        }
        return promise.future
    }

}

extension TrackingHelper {

    fileprivate static var systemFreeSize: UInt64 {
        return self.deviceData(for: .systemFreeSize) ?? 0
    }

    fileprivate static var systemSize: UInt64 {
        return self.deviceData(for: .systemSize) ?? 0
    }

    private static func deviceData(for key: FileAttributeKey) -> UInt64? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            return nil
        }

        guard let deviceData = try? FileManager.default.attributesOfFileSystem(forPath: path) else {
            return nil
        }

        guard let value = deviceData[key] as? NSNumber else {
            return nil
        }

        return value.uint64Value
    }

}
