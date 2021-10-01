//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct XikoloWidgetBundle: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget { // swiftlint:disable:this let_var_whitespace
        ContinueLearningWidget()

        #if COURSE_DATES_ENABLED
        CourseDateStatisticsWidget()
        NextCourseDateWidget()
        CourseDateOverviewWidget()
        #endif
    }

}
