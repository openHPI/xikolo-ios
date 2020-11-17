//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class DashboardViewController: CustomWidthViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if Brand.default.features.showCourseDates {
            let dateOverviewViewController = R.storyboard.courseDateOverview.instantiateInitialViewController().require()
            self.addContentController(dateOverviewViewController)
        }

        let currentCoursesViewController = R.storyboard.courseOverview.instantiateInitialViewController().require()
        currentCoursesViewController.configuration = .currentCourses
        self.addContentController(currentCoursesViewController)

        let completedCoursesViewController = R.storyboard.courseOverview.instantiateInitialViewController().require()
        completedCoursesViewController.configuration = .completedCourses
        self.addContentController(completedCoursesViewController)

        self.addRefreshControl()
        self.refresh()
    }

    private func addContentController(_ child: UIViewController) {
        self.addChild(child)
        self.stackView.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.createEvent(.visitedDashboard, on: self)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            self.navigationController?.navigationBar.sizeToFit()
        }
    }

}

extension DashboardViewController: RefreshableViewController {

    var refreshableScrollView: UIScrollView {
        return self.scrollView
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        let courseFuture = CourseHelper.syncAllCourses()

        // This view controller is always loaded even if the user is not logged in due to the fact
        // that the view controller is embedded in a UITabBarController. So we have to check the
        // login state of user in order to avoid a failing API request
        if Brand.default.features.showCourseDates && UserProfileHelper.shared.isLoggedIn {
            return courseFuture.flatMap { _ in
                return CourseDateHelper.syncAllCourseDates()
            }.asVoid()
        } else {
            return courseFuture.asVoid()
        }
    }

}
