//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI

extension Color {

    static let appPrimary: Color = {
        guard let primaryUIColor = UIColor(named: "primary", in: Bundle.appBundle, compatibleWith: nil) else { return .gray }
        return Color(primaryUIColor)
    }()

}
