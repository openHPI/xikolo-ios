//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SwiftUI
import WidgetKit

struct CourseView: View {

    var course: CourseViewModel

    let appIconWidth: Int = 20

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: course.image ?? UIImage())
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fit)
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

            Text(course.title)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(Color.primary)

            if let itemTitle = course.itemTitle {
                Text(itemTitle)
                .font(.system(size: 12))
                    .foregroundColor(Color.secondary)
                    .lineLimit(1)
            }
        }
    }

}


struct CourseView_Previews: PreviewProvider {

    static var exampleCourse: CourseViewModel {
        CourseViewModel(title: "This is an interesting course", itemTitle: "Continue learning")
    }

    static var previews: some View {
        Group {
            CourseView(course: exampleCourse)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

        }
    }

}
