//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

enum CourseArea: CaseIterable {

    case learnings
    case discussions
    case progress
    case collabSpace
    case courseDetails
    case documents
    case announcements
    case recap
    case certificates

    static var availableAreas: [CourseArea] = {
        return Self.allCases.filter(\.isAvailable)
    }()

    var accessibleWithoutEnrollment: Bool {
        return self == .courseDetails || self == .certificates
    }

    var isAvailable: Bool {
        switch self {
        case .collabSpace:
            return Brand.default.features.enableCollabSpaces
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
        case .progress:
            return NSLocalizedString("course-area.view.progress.title", comment: "title of progress view of course view")
        case .collabSpace:
            return NSLocalizedString("course-area.view.collab-space.title", comment: "title of collab spaces view of course view")
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
            return R.storyboard.announcements.instantiateInitialViewController()
        case .recap:
            return R.storyboard.webViewController.instantiateInitialViewController()
        case .certificates:
            return R.storyboard.courseCertificates.instantiateInitialViewController()
        case .progress:
            return R.storyboard.courseProgress.instantiateInitialViewController()
        case .collabSpace:
            return R.storyboard.webViewController.instantiateInitialViewController()
        }
    }

}
