//
//  BingeMediaSelectionDelegate.swift
//  Binge
//
//  Created by Max Bothe on 21.01.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import AVFoundation
import UIKit

protocol BingeMediaSelectionDelegate: AnyObject { // TODO: split into delegate and datasource
    var currentMediaSelection: AVMediaSelection? { get }
    func select(_ option: AVMediaSelectionOption?, in group: AVMediaSelectionGroup)
    func didCloseMediaSelection()
}
