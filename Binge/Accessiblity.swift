//
//  Accessiblity.swift
//  Binge
//
//  Created by Max Bothe on 20.04.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

var trueUnlessReduceMotionEnabled: Bool {
    return !UIAccessibility.isReduceMotionEnabled
}
