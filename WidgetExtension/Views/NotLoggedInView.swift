//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI

struct NotLoggedInView: View {

    var body: some View {
        VStack {
            Text("Log into your account")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("to the widget contentz")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
    }

}
