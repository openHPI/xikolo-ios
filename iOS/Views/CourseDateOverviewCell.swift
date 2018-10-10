//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseDateOverviewCell: UITableViewCell {

    @IBOutlet private weak var summaryView: CourseDateSummaryView!
    @IBOutlet private weak var nextUpView: CourseDateNextUpView!

    weak var delegate: CourseDateOverviewDelegate? {
        didSet {
            self.summaryView.delegate = self.delegate
        }
    }

    func loadData() {
        self.summaryView.loadData()
        self.nextUpView.loadData()
    }

}

protocol CourseDateOverviewDelegate: AnyObject {

    func openCourseDateList()

}
