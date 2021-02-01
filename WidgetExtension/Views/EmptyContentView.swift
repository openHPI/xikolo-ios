//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI

struct EmptyContentView: View {

    var body: some View {
        VStack {
            Text("Enroll into more courses")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("to see your course information here")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
    }

}
