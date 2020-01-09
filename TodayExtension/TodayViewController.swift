//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let currentCoursesViewController = R.storyboard.courseOverview.instantiateInitialViewController().require()
        currentCoursesViewController.configuration = .currentCourses
        self.addContentController(currentCoursesViewController)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
