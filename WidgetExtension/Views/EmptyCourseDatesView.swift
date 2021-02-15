//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EmptyCourseDatesView: View {

    var body: some View {
        VStack(spacing: 6) {
            Text("No upcoming course dates")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("Enroll to new courses to see the course dates here")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
    }

}

struct EmptyCourseDatesView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyCourseDatesView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyCourseDatesView()
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}

