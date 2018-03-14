//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

class CourseItemHeader : UITableViewHeaderFooterView {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var actionsButton: UIButton!

    private var section: CourseSection?
    weak var delegate: CourseItemHeaderDelegate?

    func configure(for section: CourseSection, inOfflineMode: Bool) {
        self.section = section
        self.titleView.text = section.title
        self.actionsButton.isHidden = !section.hasUserActions
        self.actionsButton.isEnabled = !inOfflineMode && !section.userActions.isEmpty
    }

    @IBAction func tappedActionsButton(_ sender: UIButton) {
        guard let actions = self.section?.userActions, !actions.isEmpty else { return }
        self.delegate?.showAlert(with: actions, on: self.actionsButton)
    }

}

protocol CourseItemHeaderDelegate: class {

    func showAlert(with actions: [UIAlertAction], on anchor: UIView)

}
