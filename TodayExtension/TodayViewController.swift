//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import NotificationCenter
import UIKit

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet private weak var loginRequestedLabel: UILabel!
    @IBOutlet private weak var counterStackView: UIStackView!
    @IBOutlet private weak var todayCountLabel: UILabel!
    @IBOutlet private weak var nextCountLabel: UILabel!
    @IBOutlet private weak var allCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disallow the today widget to be expanded or contracted.
        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact

        if #available(iOS 11, *) {
            // The large title font is not avaiable on iOS 10 and the storyboard file fails to provide a suitable fallback value.
            // Therefore, we set the font to .title1 in the storyboard file and upgrade to .largeTitle for iOS 11 manually.
            self.todayCountLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            self.nextCountLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            self.allCountLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        }

        self.updateView()
        self.loadData()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let loginStateChanged = self.updateView()
        let contentChanged = self.loadData()
        let result: NCUpdateResult = contentChanged || loginStateChanged ? .newData : .noData
        completionHandler(result)
    }

    @discardableResult private func updateView() -> Bool {
        let loginStateChange = UserProfileHelper.shared.isLoggedIn != self.loginRequestedLabel.isHidden
        self.counterStackView.isHidden = !UserProfileHelper.shared.isLoggedIn
        self.loginRequestedLabel.isHidden = UserProfileHelper.shared.isLoggedIn
        return loginStateChange
    }

    @discardableResult private func loadData() -> Bool {
        let oldValues = [
            self.todayCountLabel.text,
            self.nextCountLabel.text,
            self.allCountLabel.text,
        ]

        self.todayCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1))
        self.nextCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7))
        self.allCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.allCourseDates)

        let newValues  = [
            self.todayCountLabel.text,
            self.nextCountLabel.text,
            self.allCountLabel.text,
        ]

        return oldValues != newValues
    }

    private func formattedItemCount(for fetchRequest: NSFetchRequest<CourseDate>) -> String {
        if let count = try? CoreDataHelper.viewContext.count(for: fetchRequest) {
            return String(count)
        } else {
            return "-"
        }
    }

    @objc private func handleBackgroundTap() {
        guard let urlScheme = Bundle.main.urlScheme else { return }
        guard let url = URL(string: "\(urlScheme)://dashboard") else { return }
        self.extensionContext?.open(url, completionHandler: nil)
    }

}
