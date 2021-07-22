//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateView: View {

    var courseDate: CourseDateViewModel

    var body: some View {
        VStack {
            VStack(alignment: .trailing, spacing: 4) {
                Text("course-date-next.headline")
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.9)
                (Text("in ") + Text(courseDate.date, style: .relative))
                    .font(.system(size: 12))
                    .multilineTextAlignment(.trailing)
                    .minimumScaleFactor(0.9)
                Text(courseDate.formattedFullDate)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.9)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .layoutPriority(3)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                if let courseTitle = courseDate.courseTitle {
                    Text(courseTitle)
                        .font(.system(size: 10))
                        .foregroundColor(.appPrimary)
                        .layoutPriority(1)
                        .minimumScaleFactor(0.8)
                }

                Text(courseDate.itemTitle)
                    .font(.system(size: 12))
                    .layoutPriority(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .widgetURL(courseDate.url)
    }

}

struct CourseDateView_Previews: PreviewProvider {

    static var exampleCourseDate: CourseDateViewModel {
        return CourseDateViewModel(
            courseTitle: "an interesting course",
            itemTitle: "item title",
            date: Date().advanced(by: 56 * 60 * 60)
        )
    }

    static var previews: some View {
        Group {
            CourseDateView(courseDate: exampleCourseDate)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            CourseDateView(courseDate: exampleCourseDate)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
