//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class UnavailableContentViewController: UIViewController {

    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet private weak var reloadButton: LoadingButton!

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
        self.reloadButton.tintColor = Brand.default.colors.primary
        self.reloadButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    @IBAction private func reloadItem() {
        guard let item = self.courseItem else { return }

        self.reloadButton.startAnimation()
        let dispatchTime = 500.milliseconds.fromNow
        CourseItemHelper.syncCourseItemWithContent(item).earliest(at: dispatchTime).onComplete { [weak self] _ in
            self?.reloadButton.stopAnimation()
        }.onSuccess { [weak self] _ in
            self?.delegate?.reload(animated: false)
        }
    }

}

extension UnavailableContentViewController: CourseItemContentViewController {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
