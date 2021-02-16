//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

#if COURSE_DATES_ENABLED

@main
struct XikoloWidgetBundle: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        ContinueLearningWidget()
        CourseDateStatisticsWidget()
        NextCourseDateWidget()
        CourseDateOverviewWidget()
    }

}

#else

@main
struct XikoloWidgetBundle: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        ContinueLearningWidget()
    }

}

#endif
