//
//  BingePlaybackRateDelegate.swift
//  Binge
//
//  Created by Max Bothe on 13.02.19.
//  Copyright © 2019 Hasso-Plattener-Institut. All rights reserved.
//

protocol BingePlaybackRateDelegate: AnyObject {
    var currentRate: Float { get }
    func changeRate(to: Float)
}
