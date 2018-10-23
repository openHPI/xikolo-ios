//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class ProctoredItemViewController: UIViewController {

    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    private var courseItem: CourseItem? {
        didSet {
            guard self.viewIfLoaded != nil else { return }
            self.itemTitleLabel.text = self.courseItem?.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.textColor = Brand.default.colors.primary
        self.itemTitleLabel.text = self.courseItem?.title
    }

}

extension ProctoredItemViewController: CourseItemContentViewController {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }
}
