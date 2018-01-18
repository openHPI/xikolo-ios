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
    consoleDestination.outputLevel = .verbose
    consoleDestination.showLogIdentifier = false
    consoleDestination.showFunctionName = false
    consoleDestination.showThreadName = false
    consoleDestination.showLevel = true
    consoleDestination.showFileName = false
    consoleDestination.showLineNumber = false
    consoleDestination.showDate = true

    log.add(destination: consoleDestination)
    log.logAppDetails()

    log.filters = [FileNameFilter(excludeFrom: ["SyncEngine.swift"], excludePathWhenMatching: true)]
    return log
}()
