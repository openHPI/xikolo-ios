//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateOverviewView: View {

    // todo get brand color from app bundle

    var courseDateOverview: CourseDateOverviewViewModel

    var body: some View {
        VStack {
            Text("Course Date Overview")
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            HStack {
                Text("Today")
                Spacer()
                Text("\(courseDateOverview.todayCount)")
                    .font(.callout)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            Spacer()
            HStack {
                Text("Next 7 Days")
                Spacer()
                Text("\(courseDateOverview.nextCount)")
                    .font(.callout)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            Spacer()
            HStack {
                Text("All")
                Spacer()
                Text("\(courseDateOverview.allCount)")
                    .font(.callout)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
    }

}

struct CourseDateOverviewView_Previews: PreviewProvider {

    static var exampleCourseDateOverview: CourseDateOverviewViewModel {
        CourseDateOverviewViewModel(todayCount: 1, nextCount: 2, allCount: 4)
    }

    static var previews: some View {
        Group {
            CourseDateOverviewView(courseDateOverview: exampleCourseDateOverview)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))

        }
    }

}
