//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CourseDateStatisticsView: View {

    var courseDateStatistics: CourseDateStatisticsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Course Date Overview")
                .font(.system(size: 12))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Divider()
            VStack(spacing: 4) {
                HStack {
                    Text("Today")
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(courseDateStatistics.todayCount)")
                        .pillStyle()
                }
                HStack {
                    Text("Next 7 Days")
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(courseDateStatistics.nextCount)")
                        .pillStyle()
                }
                HStack {
                    Text("All")
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(courseDateStatistics.allCount)")
                        .pillStyle()
                }
            }
        }
    }

}

private extension Text {

    func pillStyle() -> some View {
        self
            .font(.system(size: 12))
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .foregroundColor(Color(UIColor.systemBackground))
            .background(Color.appPrimary)
            .clipShape(Capsule())
    }

}

struct CourseDateOverviewView_Previews: PreviewProvider {

    static var exampleCourseDateOverview: CourseDateStatisticsViewModel {
        CourseDateStatisticsViewModel(todayCount: 1, nextCount: 2, allCount: 4)
    }

    static var previews: some View {
        Group {
            CourseDateStatisticsView(courseDateStatistics: exampleCourseDateOverview)
                .padding()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }

}
