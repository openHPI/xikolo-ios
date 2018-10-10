//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

enum CourseArea {

    case learnings
    case discussions
    case courseDetails
    case documents
    case announcements
    case recap
    case certificates

    static var availableAreas: [CourseArea] = {
        let values: [CourseArea] = [
            .learnings,
            .discussions,
            .courseDetails,
            .documents,
            .announcements,
            .recap,
            .certificates,
        ]

        return values.filter { $0.isAvailable }
    }()

    var acessibleWithoutEnrollment: Bool {
        return self == .courseDetails || self == .certificates
    }

    var isAvailable: Bool {
        switch self {
        case .documents:
            return Brand.default.features.enableDocuments
        case .recap:
            return Brand.default.features.enableRecap
        default:
            return true
        }
    }

    var title: String {
        switch self {
        case .learnings:
            return NSLocalizedString("course-area.view.learnings.title", comment: "title of learnings view of course view")
        case .discussions:
            return NSLocalizedString("course-area.view.discussions.title", comment: "title of discussions view of course view")
        case .courseDetails:
            return NSLocalizedString("course-area.view.course-details.title", comment: "title of course details view of course view")
        case .documents:
            return NSLocalizedString("course-area.view.documents.title", comment: "title of documents view of course view")
        case .announcements:
            return NSLocalizedString("course-area.view.announcements.title", comment: "title of announcements view of course view")
        case .recap:
            return NSLocalizedString("course-area.view.recap.title", comment: "title of recap view of course view")
        case .certificates:
            return NSLocalizedString("course-area.view.certificates.title", comment: "title of certificates view of course view")
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
        case .documents:
            return R.storyboard.courseDocuments.instantiateInitialViewController()
        case .announcements:
            return R.storyboard.tabNews.announcementListViewController()
        case .recap:
            return R.storyboard.webViewController.instantiateInitialViewController()
        case .certificates:
            return R.storyboard.courseCertificates.instantiateInitialViewController()
        }
    }

}
