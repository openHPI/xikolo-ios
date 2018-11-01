//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public struct SingleSignOnConfiguration: Decodable {
    let provider: SingleSignOnProvider
    let platformTitle: String
    public let buttonTitle: String
}

enum SingleSignOnProvider: String, Decodable {
    case saml
    case oidc
}
