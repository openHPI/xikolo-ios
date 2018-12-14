//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class LTIHintViewController: UIViewController {

    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet weak var instructionsView: UILabel!
    @IBOutlet private weak var startButton: UIButton!

    weak var delegate: CourseItemViewController?

    private var courseItem: CourseItem? {
        didSet {
            guard self.viewIfLoaded != nil else { return }
            self.itemTitleLabel.text = self.courseItem?.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemTitleLabel.text = self.courseItem?.title
        self.startButton.tintColor = Brand.default.colors.primary
        self.startButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    @IBAction private func startItem() {
        guard let item = self.courseItem else { return }
        self.perf

    }

}

extension LTIHintViewController: CourseItemContentViewController {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
