//
//  Created for xikolo-ios under GPL-3.0 license.
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

        if FeatureHelper.hasFeature(.courseDates) {
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
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

    @objc private func coreDataChange(notification: Notification) {
        let featureSyncDetected = notification.includesChanges(for: Feature.self, keys: [.inserted, .updated, .refreshed])
        if featureSyncDetected {
            self.addCourseDateOverviewIfNeeded()
        }
    }

    private func addCourseDateOverviewIfNeeded() {
        if self.viewIfLoaded == nil { return }
        if self.children.contains(where: { $0 is CourseDateOverviewViewController }) { return }
        guard FeatureHelper.hasFeature(.courseDates) else { return }

        let dateOverviewViewController = R.storyboard.courseDateOverview.instantiateInitialViewController().require()
        self.addChild(dateOverviewViewController)
        self.stackView.insertArrangedSubview(dateOverviewViewController.view, at: 0)
        dateOverviewViewController.didMove(toParent: self)
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
        if FeatureHelper.hasFeature(.courseDates) && UserProfileHelper.shared.isLoggedIn {
            return courseFuture.flatMap { _ in
                return CourseDateHelper.syncAllCourseDates()
            }.asVoid()
        } else {
            return courseFuture.asVoid()
        }
    }

}
