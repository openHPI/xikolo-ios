//
//  Int+TimeInterval.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.01.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import Foundation

public extension Int {

    public var days: TimeInterval {
        return TimeInterval(self*24*60*60)
    }

    public var day: TimeInterval {
        return self.days
    }

}
