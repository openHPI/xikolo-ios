//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.scrollView.refreshControl = refreshControl

        self.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrackingHelper.shared.createEvent(.visitedDashboard)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.dashboardViewController.embedCurrentCourses(segue: segue) {
            typedInfo.destination.fetchRequest = CourseHelper.FetchRequest.enrolledCourses
        } else if let typedInfo = R.segue.dashboardViewController.embedCompletedCourses(segue: segue) {
            typedInfo.destination.fetchRequest = CourseHelper.FetchRequest.enrolledCourses
        }
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.scrollView.refreshControl?.endRefreshing()
            }
        }

        CourseHelper.syncAllCourses().onComplete { _ in
            CourseDateHelper.syncAllCourseDates().onComplete { _ in
                stopRefreshControl()
            }
        }
    }

}
