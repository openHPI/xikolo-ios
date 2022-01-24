//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class UserProfileCell: UITableViewCell {

    @IBOutlet private weak var outerStackView: UIStackView!
    @IBOutlet private weak var labelsStackView: UIStackView!

    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var nameView: UILabel!
    @IBOutlet private weak var displayNameView: UILabel!
    @IBOutlet private weak var emailView: UILabel!
    @IBOutlet private weak var loadingLabel: UILabel!

    private var user: User? {
        didSet {
            self.updateProfileInfo()
        }
    }

    weak var tableView: UITableView?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.nameView.text = nil
        self.displayNameView.text = nil
        self.emailView.text = nil

        self.loadData()
        self.adaptToContentSizeCategoryChange()

        self.traitCollection.performAsCurrent {
             self.profileImage.layer.borderColor = ColorCompatibility.systemGray.cgColor
        }

        self.profileImage.sd_imageTransition = .fade

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adaptToContentSizeCategoryChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.adaptToContentSizeCategoryChange()

        if #available(iOS 13, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.profileImage.layer.borderColor = ColorCompatibility.systemGray.cgColor
            }
        }
    }

    @objc func loadData() {
        guard UserProfileHelper.shared.isLoggedIn else {
            self.user = nil
            return
        }

        CoreDataHelper.viewContext.perform {
            if let userId = UserProfileHelper.shared.userId {
                let fetchRequest = UserHelper.FetchRequest.user(withId: userId)
                self.user = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value
            } else {
                self.user = nil
            }
        }
    }

    private func updateProfileInfo() {
        self.profileImage.sd_setImage(with: self.user?.avatarURL, placeholderImage: R.image.personCropCircle())
        self.profileImage.layer.cornerRadius = self.user == nil ? 0 : self.profileImage.bounds.width / 2

        self.nameView.text = self.user?.profile?.fullName
        self.displayNameView.text = self.user?.name
        self.displayNameView.isHidden = self.user?.profile?.fullName == self.user?.name || self.user?.name == nil || self.user?.profile == nil
        self.emailView.text = self.user?.profile?.email

        self.loadingLabel.isHidden = self.user != nil

        UIView.performWithoutAnimation {
            self.sizeToFit()
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        }
    }

    @objc private func adaptToContentSizeCategoryChange() {
        let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let compactHorizontalSizeClass = self.traitCollection.horizontalSizeClass == .compact
        let stackedVertically = isAccessibilityCategory && compactHorizontalSizeClass

        self.outerStackView.axis = stackedVertically ? .vertical : .horizontal
        self.labelsStackView.alignment = stackedVertically ? .center : .leading

        let textAlignment: NSTextAlignment = stackedVertically ? .center : .natural
        self.nameView.textAlignment = textAlignment
        self.displayNameView.textAlignment = textAlignment
        self.emailView.textAlignment = textAlignment
    }

}
