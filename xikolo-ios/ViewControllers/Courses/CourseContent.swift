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
            let storyboard = UIStoryboard(name: "CourseLearnings", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: CourseItemListViewController.self)
            viewController.course = course
            return viewController
        case .discussions:
            let storyboard = UIStoryboard(name: "WebViewController", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: WebViewController.self)
            if let slug = course.slug {
                viewController.url = Routes.courses.appendingPathComponents([slug, "pinboard"])
            }

            return viewController
        case .courseDetails:
            let storyboard = UIStoryboard(name: "CourseDetails", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: CourseDetailViewController.self)
            viewController.course = course
            return viewController
        case .announcements:
            let announcementsStoryboard = UIStoryboard(name: "TabNews", bundle: nil)
            let loadedViewController = announcementsStoryboard.instantiateViewController(withIdentifier: "AnnouncementsListViewController")
            let viewController = loadedViewController.require(toHaveType: AnnouncementsListViewController.self)
            viewController.course = course
            return viewController
        case .certificates:
            let storyboard = UIStoryboard(name: "CourseCertificates", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController().require(hint: "Initial view controller required")
            let viewController = initialViewController.require(toHaveType: CertificatesListViewController.self)
            viewController.course = course
            return viewController
        }
    }

//    switch self {
//    case .learnings:
//    case .discussions:
//    case .courseDetails:
//    case .announcements:
//    }
}
