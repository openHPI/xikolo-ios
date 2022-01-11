//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

public protocol ErrorReporter {

    func report(_ error: Error)
    func remember(_ value: Any, forKey key: String)

}

public class ErrorManager: ErrorReporter {

    private var reporters: [ErrorReporter] = []

    public static let shared = ErrorManager()

    public func register(reporter: ErrorReporter) {
        self.reporters.append(reporter)
    }

    public func report(_ error: Error) {
        self.reporters.forEach { $0.report(error) }
    }

    public func remember(_ value: Any, forKey key: String) {
        self.reporters.forEach { $0.remember(value, forKey: key) }
    }

    func reportAPIError(_ error: XikoloError) {
        guard case .synchronization(.api) = error else { return }
        if case let .synchronization(.api(.response(statusCode: statusCode, headers: _))) = error,
           !(200 ... 299 ~= statusCode || statusCode == 406 || statusCode == 503) { return }
        self.report(error)
    }

}
