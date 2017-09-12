//
//  AnalyticsHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 27.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures
import Result

class AnalyticsHelper {

    private static let queue = DispatchQueue(label: "de.xikolo.analytics-queue")

    class func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(AnalyticsHelper.check), name: NotificationKeys.reachabilityChanged, object: nil)
        self.check()
    }

    @objc class func check() {
        do {
            let eventCount = try CoreDataHelper.backgroundContext.count(for: TrackingHelper.getTrackingEventRequest())
            if eventCount > 0 {
                self.queue.async {
                    self.uploadTrackingEvents()
                }
            }
        } catch {
            print("\(error)")
        }
    }

    class func uploadTrackingEvents() {
//        guard ReachabilityHelper.reachability.currentReachabilityStatus == .reachableViaWiFi else { return }
        let events: [TrackingEvent]
        do {
            events = try CoreDataHelper.backgroundContext.fetch(TrackingHelper.getTrackingEventRequest())
            guard events.count > 0 else { return }
            events.traverse { event in
                return SpineHelper.save(TrackingEventSpine(event)).map { _ -> Future<Void, NoError> in
                    CoreDataHelper.backgroundContext.delete(event)
                    return Future { complete in complete(.success()) }
                }.onFailure { error in
                    print("error")
                }
            }.onComplete { _ in
                DispatchQueue.main.sync {
                    CoreDataHelper.saveContext()
                }
                self.queue.async {
                    self.uploadTrackingEvents()
                }
            }
        } catch {
            print("Failed to fetch tracking events: \(error)")
        }
    }

}
