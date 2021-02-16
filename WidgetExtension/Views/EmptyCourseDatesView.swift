//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EmptyCourseDatesView: View {

    var body: some View {
        VStack(spacing: 6) {
            Text("empty-course-dates.headline")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            Text("empty-course-dates.subline")
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
        }
        .padding()
    }

}

struct EmptyCourseDatesView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyCourseDatesView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyCourseDatesView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}

