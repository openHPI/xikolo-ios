//
//  AnalyticsHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 27.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class AnalyticsHelper {

    class func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(AnalyticsHelper.check), name: NotificationKeys.reachabilityChanged, object: nil)
        check()
    }

    @objc class func check() {
        do {
            let eventCount = try CoreDataHelper.backgroundContext.count(for: TrackingHelper.getTrackingEventRequest())
            if eventCount > 0 {
                self.uploadTrackingEvents()
            }
        } catch {
            print("\(error)")
        }
    }

    class func uploadTrackingEvents() {
        guard ReachabilityHelper.reachability.currentReachabilityStatus == .reachableViaWiFi else { return }
        var events: [TrackingEvent]
        do {
            events = try CoreDataHelper.backgroundContext.fetch(TrackingHelper.getTrackingEventRequest())
            guard events.count > 0 else { return }
            for event in events {
                SpineHelper.save(TrackingEventSpine(event)).onSuccess(callback: { (_) in
                    CoreDataHelper.backgroundContext.delete(event)
                })
            }
        } catch {
            print("Failed to fetch tracking events: \(error)")
        }
        RetryHelper.after(interval: 60.0).onSuccess { check() }
    }

}
