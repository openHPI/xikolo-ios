//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseDateOverviewCell: UITableViewCell {

    @IBOutlet private weak var summaryView: CourseDateSummaryView!
    @IBOutlet private weak var nextUpView: CourseDateNextUpView!

    weak var delegate: CourseDateOverviewDelegate? {
        didSet {
            self.summaryView.delegate = self.delegate
        }
    }

    static func applyCardLook(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 6.0
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 8.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    func loadData() {
        self.summaryView.loadData()
        self.nextUpView.loadData()
    }

}

protocol CourseDateOverviewDelegate: AnyObject {

    func openCourseDateList()

}
