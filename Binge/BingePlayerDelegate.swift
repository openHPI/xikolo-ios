//
//  BingePlayerDelegate.swift
//  Binge
//
//  Created by Max Bothe on 13.02.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

public protocol BingePlayerDelegate: AnyObject {
    func didStartPlayback()
    func didPausePlayback()
    func didChangePlaybackRate(from oldRate: Float, to newRate: Float)
    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval)
    func didReachEndofPlayback()
    func didChangeLayoutState(to state: LayoutState)
    func didChangeOrientation(to orientation: UIInterfaceOrientation)
}

public extension BingePlayerDelegate {
    func didStartPlayback() {}
    func didPausePlayback() {}
    func didChangePlaybackRate(from oldRate: Float, to newRate: Float) {}
    func didSeek(from oldTime: TimeInterval, to newTime: TimeInterval) {}
    func didReachEndofPlayback() {}
    func didChangeLayoutState(to state: LayoutState) {}
    func didChangeOrientation(to orientation: UIInterfaceOrientation) {}
}
