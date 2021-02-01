//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct XikoloWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ContinueLearningWidget()
        CourseDateOverviewWidget()
    }
}
