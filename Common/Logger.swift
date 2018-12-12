//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import os

let log = Logger(subsystem: "de.xikolo.common", category: "Common")

public struct Logger {

    private let log: OSLog

    public init(subsystem: String, category: String) {
        self.log = OSLog(subsystem: subsystem, category: category)
    }

    private func log(type: OSLogType, file: String, _ message: String, _ args: [CVarArg]) {
        let expendedMessage = String(format: message, arguments: args)
        if let url = URL(string: file) {
            os_log("[%@] %@", log: self.log, type: type, url.lastPathComponent, expendedMessage)
        } else {
            os_log("%@", log: self.log, type: type, expendedMessage)
        }
    }

    public func info(_ message: String, file: String = #file, _ args: CVarArg...) {
        self.log(type: .info, file: file, message, args)
    }

    public func debug(_ message: String, file: String = #file, _ args: CVarArg...) {
        self.log(type: .debug, file: file, message, args)
    }

    public func warning(_ message: String, file: String = #file, _ args: CVarArg...) {
        self.log(type: .default, file: file, message, args)
    }

    public func error(_ message: String, file: String = #file, _ args: CVarArg..., error: Error? = nil) {
        var builtArgs = args
        var builtMessage: String = message

        if let error = error {
            let originalMessage = String(format: message, arguments: args)
            builtMessage = "%@ ===> Error found: %@"
            builtArgs = [originalMessage, String(reflecting: error)]
        }

        self.log(type: .error, file: file, builtMessage, builtArgs)
    }

    public func fault(_ message: String, file: String = #file, _ args: CVarArg...) {
        self.log(type: .fault, file: file, message, args)
    }
}
