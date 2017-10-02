//
//  DispatchTimeInterval+DispatchTime.swift
//  xikolo-ios
//
//  Created by Max Bothe on 25.09.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

public extension DispatchTimeInterval {

    public var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }

}
