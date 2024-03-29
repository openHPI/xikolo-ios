//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct SingleSignOnConfiguration: Decodable {
    let provider: SingleSignOnProvider
    let platformTitle: String
    public let buttonTitle: String
    public let disabledRegistration: Bool
    public let disabledPasswordLogin: Bool
}

enum SingleSignOnProvider: String, Decodable {
    case saml
    case oidc
}
