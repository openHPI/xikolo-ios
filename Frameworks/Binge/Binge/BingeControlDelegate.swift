//
//  BingeControlDelegate.swift
//  Binge
//
//  Created by Max Bothe on 13.02.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

import UIKit

protocol BingeControlDelegate: AnyObject {
    func startPlayback()
    func pausePlayback()
    func seekTo(progress: Double)
    func seekForwards()
    func seekBackwards()

    func toggleFullScreenMode()
    func togglePictureInPictureMode()
    func showMediaSelection(for sourceView: UIView)

    func dismissPlayer()
}
