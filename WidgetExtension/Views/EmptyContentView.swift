//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

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

struct EmptyContentView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyContentView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyContentView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
