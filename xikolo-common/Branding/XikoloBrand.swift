//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

protocol XikoloBrand {

    static var host: String { get }
    static var imprintURL: URL { get }
    static var privacyURL: URL { get }

    static var platformTitle: String { get }
    static var singleSignOnButtonTitle: String? { get }

    static var copyrightName: String { get }
    static var poweredByText: String? { get }

}

extension XikoloBrand {

    static var singleSignOnButtonTitle: String? {
        return nil
    }

    static var copyrightText: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "Copyright © \(currentYear) \(Self.copyrightName). All rights reserved."
    }

    static var poweredByText: String? {
        return nil
    }

    static var locale: Locale {
        if Bundle.main.localizations.contains(Locale.current.languageCode ?? Locale.current.identifier) {
            return Locale.current
        } else {
            return Locale(identifier: "en")
        }
    }

    static var feedbackRecipients: [String] {
        return ["mobile-feedback@hpi.de"]
    }

    static var feedbackSubject: String {
        return "\(UIApplication.appName) | App Feedback"
    }

}
