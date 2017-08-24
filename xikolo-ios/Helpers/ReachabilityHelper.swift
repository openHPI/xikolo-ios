//
//  Reachability.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import ReachabilitySwift

class ReachabilityHelper {

    // TODO:    good notification on reachability changed
    //          state logic
    //          connect to tableview again

    static var reachability: Reachability = {
        return Reachability(hostname: Brand.Host)!
    }()

    static var reachabilityState: State? = .offline

    enum State : String {
        case wifi = "wifi"
        case mobile = "mobile"
        case offline = "offline"
    }

    static var isOffline = false



    class func setupReachability(_ host: String? = Brand.Host) {
        NotificationCenter.default.addObserver(self, selector: #selector(ReachabilityHelper.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: self.reachabilityState)
    }

    private class func startReachabilityNotifier() {
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Failed to start reachability notification")
        }
    }

    private class func stopReachabilityNotifier() {
        self.reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.reachabilityState = nil
    }

    @objc class func reachabilityChanged(_ note: Notification) {
        guard let reachability = note.object as? Reachability else { return }

        let oldOfflineState = self.isOffline
        self.isOffline = !reachability.isReachable

        if oldOfflineState != self.isOffline {
            //self.tableView.reloadData()
        }
    }

}
