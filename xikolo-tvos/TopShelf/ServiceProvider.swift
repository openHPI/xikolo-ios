//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by Sebastian Brückner on 24.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    var topShelfStyle: TVTopShelfContentStyle {
        return .Sectioned
    }

    var topShelfItems: [TVContentItem] {
        let myCoursesSectionIdentifier = TVContentIdentifier(identifier: "my-courses", container: nil)!
        let myCoursesSection = TVContentItem(contentIdentifier: myCoursesSectionIdentifier)!
        myCoursesSection.title = NSLocalizedString("My Courses", comment: "My Courses")
        let allCoursesSectionIdentifier = TVContentIdentifier(identifier: "all-courses", container: nil)!
        let allCoursesSection = TVContentItem(contentIdentifier: allCoursesSectionIdentifier)!
        allCoursesSection.title = NSLocalizedString("All Courses", comment: "All Courses")


        let request = CourseHelper.getSectionedRequest()
        do {
            var myCoursesItems: [TVContentItem] = []
            var allCoursesItems: [TVContentItem] = []

            let courses = try CoreDataHelper.executeFetchRequest(request) as! [Course]
            for course in courses {
                let identifier = TVContentIdentifier(identifier: course.id, container: nil)!
                let item = TVContentItem(contentIdentifier: identifier)!
                item.title = course.title
                item.imageShape = .HDTV
                if let imageUrl = course.image_url {
                    item.imageURL = imageUrl
                }
                let target = XikoloURL(type: .Course, targetId: course.id)
                item.displayURL = target.toURL()

                if course.enrollment != nil {
                    myCoursesItems.append(item)
                } else {
                    allCoursesItems.append(item)
                }
            }
            myCoursesSection.topShelfItems = myCoursesItems
            allCoursesSection.topShelfItems = allCoursesItems
        } catch {
            
        }
        

        return [myCoursesSection, allCoursesSection]
    }

}
