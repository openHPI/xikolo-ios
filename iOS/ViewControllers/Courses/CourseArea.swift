//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

enum CourseArea {

    case learnings
    case discussions
    case courseDetails
    case announcements
    case certificates

    static let orderedValues: [CourseArea] = [
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

    var viewController: (UIViewController & CourseAreaViewController)? {
        switch self {
        case .learnings:
            return R.storyboard.courseLearnings.instantiateInitialViewController()
        case .discussions:
            return R.storyboard.webViewController.instantiateInitialViewController()
        case .courseDetails:
            return R.storyboard.courseDetails.instantiateInitialViewController()
        case .announcements:
            return R.storyboard.tabNews.announcementsListViewController()
        case .certificates:
            return R.storyboard.courseCertificates.instantiateInitialViewController()
        }
    }

}
