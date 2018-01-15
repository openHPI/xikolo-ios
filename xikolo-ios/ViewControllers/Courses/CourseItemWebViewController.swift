//
//  CourseItemWebViewController.swift
//  xikolo-ios
//
//  Created by Max Bothe on 28.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation


class CourseItemWebViewController: WebViewController {

    var courseItem: CourseItem! {
        didSet {
            self.setURL()
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
                    print("Warning: Failed to retrieve course item to display")
                    return
                }

                self.url = self.quizURL(for: courseItem)
            }
        }.onFailure { error in
            print("Error: \(error)")
        }
    }

    private func quizURL(for courseItem: CourseItem) -> String {
        let courseURL = Routes.COURSES_URL + (self.courseItem.section?.course?.id ?? "")
        let quizpathURL = "/items/" + courseItem.id
        return courseURL + quizpathURL
    }

}
