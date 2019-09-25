//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if Brand.default.features.showCourseDatesOnDashboard {
            let dateOverview = R.storyboard.courseDateOverview.instantiateInitialViewController().require()
            self.addContentController(dateOverview)
        }

        let viewConntroler = R.storyboard.courseOverview.instantiateInitialViewController().require()
        viewConntroler.configuration = .currentCourses
        self.addContentController(viewConntroler)

        let viewConntroler2 = R.storyboard.courseOverview.instantiateInitialViewController().require()
        viewConntroler2.configuration = .completedCourses
        self.addContentController(viewConntroler2)

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
        if Brand.default.features.showCourseDatesOnDashboard && UserProfileHelper.shared.isLoggedIn {
            return courseFuture.flatMap { _ in
                return CourseDateHelper.syncAllCourseDates()
            }.asVoid()
        } else {
            return courseFuture.asVoid()
        }
    }

}
