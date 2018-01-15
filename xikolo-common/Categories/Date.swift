//
//  Date.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.01.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import Foundation

extension Date {

    func subtractingTimeInterval(_ timeInterval: TimeInterval) -> Date {
        return self.addingTimeInterval(-1*timeInterval)
    }

}
