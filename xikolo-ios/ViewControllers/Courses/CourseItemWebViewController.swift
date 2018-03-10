//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

class CourseItemWebViewController: WebViewController {

    var courseItem: CourseItem! {
        didSet {
            self.setURL()
            CrashlyticsHelper.shared.setObjectValue("item_id", forKey: self.courseItem.id)
        }
    }

    private func setURL() {
        if self.courseItem.content != nil {
            self.url = self.quizURL(for: self.courseItem)
            return
        }

        CourseItemHelper.syncCourseItemWithContent(self.courseItem).onSuccess { syncResult in
            CoreDataHelper.viewContext.perform {
                guard let courseItem = CoreDataHelper.viewContext.existingTypedObject(with: syncResult.objectId) as? CourseItem else {
                    log.warning("Failed to retrieve course item to display")
                    return
                }

                self.url = self.quizURL(for: courseItem)
            }
        }.onFailure { error in
            CrashlyticsHelper.shared.recordError(error)
            log.error("\(error)")
        }
    }

    private func quizURL(for courseItem: CourseItem) -> String {
        let courseURL = Routes.COURSES_URL + (self.courseItem.section?.course?.id ?? "")
        let quizpathURL = "/items/" + courseItem.id
        return courseURL + quizpathURL
    }

}
