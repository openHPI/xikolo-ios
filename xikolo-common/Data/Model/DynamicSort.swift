//
//  DynamicSort.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 14.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation


@objc protocol DynamicSort {

    var order: NSNumber? {get set}

    func computeOrder()

}
