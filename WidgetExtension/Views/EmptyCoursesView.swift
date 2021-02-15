//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EmptyCoursesView: View {

    var body: some View {
        VStack(spacing: 6) {
            Text("Enroll to more courses")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("to see your course information here")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
    }

}

struct EmptyCoursesView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyCoursesView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyCoursesView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
