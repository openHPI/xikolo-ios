//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var counterStackView: UIStackView!
    @IBOutlet weak var todayCountLabel: UILabel!
    @IBOutlet weak var nextCountLabel: UILabel!
    @IBOutlet weak var allCountLabel: UILabel!
    @IBOutlet weak var loginRequestedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disallow the today widget to be expanded or contracted.
        extensionContext?.widgetLargestAvailableDisplayMode = .compact

        if UserProfileHelper.shared.isLoggedIn {
            hideLabel(isHidden: false)
            self.loadData()
        }
        else {
            hideLabel(isHidden: true)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        print("size change")
    }

    func hideLabel(isHidden: Bool) {
        self.counterStackView.isHidden = isHidden
        self.loginRequestedLabel.isHidden = !isHidden
    }

    func loadData() {
        self.todayCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1))
        self.nextCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7))
        self.allCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.allCourseDates)
    }

    private func formattedItemCount(for fetchRequest: NSFetchRequest<CourseDate>) -> String {
        if let count = try? CoreDataHelper.viewContext.count(for: fetchRequest) {
            return String(count)
        } else {
            return "-"
        }
    }

}
