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

    static var state: State = .offline

    enum State : String {
        case wifi = "wifi"
        case mobile = "mobile"
        case offline = "offline"
    }

    static var isOffline = false



    class func setupReachability(_ host: String?) {
        NotificationCenter.default.addObserver(self, selector: #selector(Reachability.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: self.state)
    }

    private class func startReachabilityNotifier() {
        do {
            try self.state.startNotifier()
        } catch {
            print("Failed to start reachability notification")
        }
    }

    private class func stopReachabilityNotifier() {
        self.state.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.state = nil
    }

    @objc class func reachabilityChanged(_ note: Notification) {
        guard let reachability = note.object as? Reachability else { return }

        let oldOfflinesState = self.isOffline
        self.isOffline = !state.isReachable

        if oldOfflinesState != self.isOffline {
            self.tableView.reloadData()
        }
    }

}
