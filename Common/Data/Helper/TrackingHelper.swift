//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import UIKit

public class TrackingHelper {

    public enum AnalyticsVerb: String {
        // tabs
        case visitedDashboard = "VISITED_DASHBOARD"
        case visitedAnnouncementList = "VISITED_ANNOUNCEMENTS"
        case visitedActivityStream = "VISITED_ACTIVITY_STREAM" // not used yet
        case visitedProfile = "VISITED_PROFILE" // not used yet

        // subpages
        case visitedItem = "VISITED_ITEM"
        case visitedAnnouncement = "VISITED_ANNOUNCEMENT_DETAIL"
        case visitedPinboard = "VISITED_PINBOARD"
        case visitedRecap = "VISITED_RECAP"

        // video playback
        case videoPlaybackPlay = "VIDEO_PLAY"
        case videoPlaybackPause = "VIDEO_PAUSE"
        case videoPlaybackSeek = "VIDEO_SEEK"
        case videoPlaybackEnd = "VIDEO_END"
        case videoPlaybackClose = "VIDEO_CLOSE"
        case videoPlaybackDeviceOrientationPortrait = "VIDEO_PORTRAIT"
        case videoPlaybackDeviceOrientationLandscape = "VIDEO_LANDSCAPE"
        case videoPlaybackChangeSpeed = "VIDEO_CHANGE_SPEED"

        // video download
        case videoDownloadStart = "DOWNLOADED_HLS_VIDEO"
        case videoDownloadFinished = "DOWNLOADED_HLS_VIDEO_FINISHED"
        case videoDownloadCanceled = "DOWNLOADED_HLS_VIDEO_CANCELED"

        // slides download
        case slidesDownloadStart = "DOWNLOADED_SLIDES"
        case slidesDownloadFinished = "DOWNLOADED_SLIDES_FINISHED"
        case slidesDownloadCanceled = "DOWNLOADED_SLIDES_CANCELED"

        // social
        case shareCourse = "SHARE_COURSE"
    }

    // swiftlint:disable redundant_string_enum_value
    public enum AnalyticsResourceType: String {
        case section = "section"
        case course = "course"
        case announcement = "announcement"

        // course items
        case item = "item"
        case video = "video"

        // none
        case none = "none"
    }
    // swiftlint:enable redundant_string_enum_value

    public static let shared = TrackingHelper()

    public weak var delegate: TrackingHelperDelegate?

    private init() {}

    private var networkState: String {
        switch ReachabilityHelper.connection {
        case .wifi:
            return "wifi"
        case .cellular:
            return "mobile"
        case .none:
            return "offline"
        }
    }

    private func newDefaultContext() -> [String: String] {
        let screenSize = UIScreen.main.bounds.size
        let windowSize = self.delegate?.applicationWindowSize

        var context = [
            "platform": UIApplication.platform,
            "platform_version": UIApplication.osVersion,
            "runtime": UIApplication.platform,
            "runtime_version": UIApplication.osVersion,
            "device": UIApplication.device,
            "build_version_name": UIApplication.appVersion,
            "build_version": UIApplication.appBuild,
            "screen_width": String(Int(screenSize.width)),
            "screen_height": String(Int(screenSize.height)),
            "free_space": String(describing: self.systemFreeSize),
            "total_space": String(describing: self.systemSize),
            "network": self.networkState,
        ]

        if let windowWidth = windowSize?.width {
            context["window_width"] = String(Int(windowWidth))
        }

        if let windowHeight = windowSize?.height {
            context["window_height"] = String(Int(windowHeight))
        }

        if let clientId = UIDevice.current.identifierForVendor?.uuidString {
            context["client_id"] = clientId
        }

        return context
    }

    @discardableResult public func createEvent(_ verb: AnalyticsVerb, context: [String: String?] = [:]) -> Future<Void, XikoloError> {
        return self.createEvent(verb, resourceType: .none, resourceId: "00000000-0000-0000-0000-000000000000", context: context)
    }

    @discardableResult public func createEvent(_ verb: AnalyticsVerb, inCourse course: Course, context: [String: String?] = [:]) -> Future<Void, XikoloError> {
        return self.createEvent(verb, resourceType: .course, resourceId: course.id, context: context)
    }

    @discardableResult public func createEvent(_ verb: AnalyticsVerb,
                                               resourceType: AnalyticsResourceType,
                                               resourceId: String,
                                               context: [String: String?] = [:]) -> Future<Void, XikoloError> {
        guard let userId = UserProfileHelper.shared.userId else {
            return Future(error: .trackingForUnknownUser)
        }

        let trackingUser = TrackingEventUser(uuid: userId)
        let trackingVerb = TrackingEventVerb(type: verb.rawValue)
        let trackingResource = TrackingEventResource(resourceType: resourceType, uuid: resourceId)

        let promise = Promise<Void, XikoloError>()

        DispatchQueue.main.async {
            var trackingContext = self.newDefaultContext()
            for case let (key, value) as (String, String) in context {
                trackingContext.updateValue(value, forKey: key)
            }

            #if DEBUG
                log.debug("Would have created tracking event '\(trackingVerb.type)'")
                promise.success(())
            #else
                CoreDataHelper.persistentContainer.performBackgroundTask { context in
                    TrackingEvent(user: trackingUser,
                                  verb: trackingVerb,
                                  resource: trackingResource,
                                  trackingContext: trackingContext as [String: AnyObject],
                                  inContext: context)
                    promise.complete(context.saveWithResult())
                    log.info("Created tracking event '\(trackingVerb.type)'")
                }
            #endif
        }

        return promise.future
    }

    public func setCurrentTrackingCurrentAsCookie() {
        let trackingContext = self.newDefaultContext()
        guard let trackingContextJSON = try? JSONEncoder().encode(trackingContext) else {
            return
        }

        guard let trackingContextString = String(data: trackingContextJSON, encoding: .utf8) else {
            return
        }

        let cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .domain: Routes.base.host ?? Brand.default.host,
            .path: "/",
            .name: "lanalytics-context",
            .value: trackingContextString,
        ]

        if let cookie = HTTPCookie(properties: cookieProperties) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }

}

extension TrackingHelper {

    private var systemFreeSize: UInt64 {
        return self.deviceData(for: .systemFreeSize) ?? 0
    }

    private var systemSize: UInt64 {
        return self.deviceData(for: .systemSize) ?? 0
    }

    private func deviceData(for key: FileAttributeKey) -> UInt64? {
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

public protocol TrackingHelperDelegate: AnyObject {

    var applicationWindowSize: CGSize? { get }

}
