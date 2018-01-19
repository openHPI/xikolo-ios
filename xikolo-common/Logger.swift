//
//  Logger.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.01.18.
//  Copyright © 2018 HPI. All rights reserved.
//

import XCGLogger

let log: XCGLogger = {

    let log = XCGLogger(identifier: "default", includeDefaultDestinations: false)
    let consoleDestination = ConsoleDestination(owner: nil, identifier: "default.consoleDestination")

    #if DEBUG
        consoleDestination.outputLevel = .verbose
        consoleDestination.showLogIdentifier = false
        consoleDestination.showFunctionName = false
        consoleDestination.showThreadName = false
        consoleDestination.showLevel = true
        consoleDestination.showFileName = false
        consoleDestination.showLineNumber = false
        consoleDestination.showDate = false
    #else
        consoleDestination.outputLevel = .severe
        consoleDestination.showLogIdentifier = true
        consoleDestination.showFunctionName = true
        consoleDestination.showThreadName = true
        consoleDestination.showLevel = true
        consoleDestination.showFileName = true
        consoleDestination.showLineNumber = true
        consoleDestination.showDate = true
    #endif

    log.add(destination: consoleDestination)
    log.logAppDetails()

    return log
}()
