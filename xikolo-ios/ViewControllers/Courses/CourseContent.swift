//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

enum CourseContent {

    case learnings
    case discussions
    case courseDetails
    case announcements
    case certificates

    static let orderedValues: [CourseContent] = [
        .learnings,
        .discussions,
        .courseDetails,
        .announcements,
        .certificates,
    ]

    var acessibleWithoutEnrollment: Bool {
        return self == .courseDetails || self == .certificates
    }

    var title: String {
        switch self {
        case .learnings:
            return NSLocalizedString("course-content.view.learnings.title", comment: "title of learnings view of course view")
        case .discussions:
            return NSLocalizedString("course-content.view.discussions.title", comment: "title of discussions view of course view")
        case .courseDetails:
            return NSLocalizedString("course-content.view.course-details.title", comment: "title of course details view of course view")
        case .announcements:
            return NSLocalizedString("course-content.view.announcements.title", comment: "title of announcements view of course view")
        case .certificates:
            return NSLocalizedString("course-content.view.certificates.title", comment: "title of certificates view of course view")
        }
    }

    func viewControllerConfigured(for course: Course) -> UIViewController {
        switch self {
        case .learnings:
            let viewController = R.storyboard.courseLearnings.instantiateInitialViewController().require()
            viewController.course = course
            return viewController
        case .discussions:
            let viewController = R.storyboard.webViewController.instantiateInitialViewController().require()
            if let slug = course.slug {
                viewController.url = Routes.courses.appendingPathComponents([slug, "pinboard"])
            }

            return viewController
        case .courseDetails:
            let viewController = R.storyboard.courseDetails.instantiateInitialViewController().require()
            viewController.course = course
            return viewController
        case .announcements:
            let viewController = R.storyboard.tabNews.announcementsListViewController().require()
            viewController.course = course
            return viewController
        case .certificates:
            let viewController = R.storyboard.courseCertificates.instantiateInitialViewController().require()
            viewController.course = course
            return viewController
        }
    }

}
