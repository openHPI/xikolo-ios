//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

enum EmptyStateView: View {
    case noCourses
    case noCourseDates
    case notLoggedIn

    var body: some View {
        VStack(spacing: 6) {
            headline
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
                .minimumScaleFactor(0.8)
            subline
                .multilineTextAlignment(.center)
                .font(.system(.footnote))
                .foregroundColor(Color.secondary)
                .minimumScaleFactor(0.8)
        }
        .backport.widgetPadding()
    }

    var headline: Text {
        switch self {
        case .noCourses:
            return Text("empty-courses.headline")
        case .noCourseDates:
            return Text("empty-course-dates.headline")
        case .notLoggedIn:
            return Text("not-logged-in.headline")
        }
    }

    var subline: Text {
        switch self {
        case .noCourses:
            return Text("empty-courses.subline")
        case .noCourseDates:
            return Text("empty-course-dates.subline")
        case .notLoggedIn:
            return Text("not-logged-in.subline")
        }
    }
}

struct EmptyStateView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EmptyStateView.noCourses
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyStateView.noCourseDates
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyStateView.notLoggedIn
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

            EmptyStateView.notLoggedIn
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
