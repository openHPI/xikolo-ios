//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseItemHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var actionsButton: UIButton!

    private var section: CourseSection?
    weak var delegate: UserActionsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleView.textColor = ColorCompatibility.secondaryLabel
        self.actionsButton.addDefaultPointerInteraction()
    }

    func configure(for section: CourseSection, inOfflineMode: Bool) {
        self.section = section
        self.titleView.text = section.title
        self.actionsButton.isHidden = !section.hasUserActions
        self.actionsButton.isEnabled = !inOfflineMode || !section.userActions.isEmpty
        self.actionsButton.tintColor = !inOfflineMode || !section.userActions.isEmpty ? Brand.default.colors.primary : ColorCompatibility.secondaryLabel
    }

    @IBAction private func tappedActionsButton(_ sender: UIButton) {
        guard let section = self.section else { return }

        if section.allVideosPreloaded {
            self.delegate?.showAlert(with: section.userActions, title: section.title, on: self.actionsButton)
        } else {
            let spinnerTitle = NSLocalizedString("course-section.loading-spinner.title",
                                                 comment: "title for spinner when loading section content")
            self.delegate?.showAlertSpinner(title: spinnerTitle) {
                return CourseItemHelper.syncCourseItems(forSection: section, withContentType: Video.contentType).asVoid()
            }.onSuccess { _ in
                self.delegate?.showAlert(with: section.userActions, title: section.title, on: self.actionsButton)
            }
        }

    }

}
