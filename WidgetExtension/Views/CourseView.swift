//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SwiftUI
import WidgetKit

struct CourseView: View {

    let appIconWidth: Int = 20

    var course: CourseViewModel

    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallBody
            default:
                mediumBody
            }
        }
        .widgetURL(course.url)
    }

    var smallBody: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: course.image ?? UIImage())
                    .centerCropped()
                    .background(Color.appPrimary)
                    .mask(
                        RoundedRectangle(cornerRadius: 6)
                    )
                    .shadow(color: Color.secondary.opacity(0.2), radius: 4)

                if let appIcon = UIImage.appIcon(withPreferredWidth: appIconWidth) {
                    Image(uiImage: appIcon)
                        .resizable()
                        .frame(width: CGFloat(appIconWidth), height: CGFloat(appIconWidth))
                        .background(Color.clear)
                        .mask(
                            RoundedRectangle(cornerRadius: 4)
                        )
                        .padding(4)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("continue-learning.call-to-action")
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text(course.title)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(Color.primary)
                    .minimumScaleFactor(0.9)
            }
        }

    }

    var mediumBody: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: course.image ?? UIImage())
                    .centerCropped()
                    .background(Color.appPrimary)
                    .mask(
                        RoundedRectangle(cornerRadius: 6)
                    )
                    .shadow(color: Color.secondary.opacity(0.2), radius: 4)

                if let appIcon = UIImage.appIcon(withPreferredWidth: appIconWidth) {
                    Image(uiImage: appIcon)
                        .resizable()
                        .frame(width: CGFloat(appIconWidth), height: CGFloat(appIconWidth))
                        .background(Color.clear)
                        .mask(
                            RoundedRectangle(cornerRadius: 4)
                        )
                        .padding(4)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text("continue-learning.call-to-action")
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(2)
                    .minimumScaleFactor(0.9)

                Text(course.title)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(2)
                    .minimumScaleFactor(0.9)

                if let itemTitle = course.itemTitle {
                    Text(itemTitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                        .minimumScaleFactor(0.9)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }

}

struct CourseView_Previews: PreviewProvider {

    static var exampleCourse: CourseViewModel {
        CourseViewModel(title: "This is an interesting course", itemTitle: "the title of an item")
    }

    static var previews: some View {
        Group {
            CourseView(course: exampleCourse)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            CourseView(course: exampleCourse)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
