//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class AnnouncementCell: UITableViewCell {

    static var dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)

    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var readStateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.readStateLabel.textColor = Brand.default.colors.secondary
        self.courseLabel.textColor = Brand.default.colors.secondary
    }

    func configure(for announcement: Announcement, showCourseTitle: Bool) {
        let userIsLoggedIn = UserProfileHelper.shared.isLoggedIn

        self.courseLabel.text = showCourseTitle ? announcement.course?.title : nil

        self.titleLabel.text = announcement.title
        self.titleLabel.textColor = userIsLoggedIn && announcement.visited ? ColorCompatibility.secondaryLabel : ColorCompatibility.label

        self.dateLabel.text = announcement.publishedAt.map(Self.dateFormatter.string(from:))
        self.readStateLabel.isHidden = !userIsLoggedIn || announcement.visited
        self.separatorView.isHidden = !userIsLoggedIn || announcement.visited || announcement.publishedAt == nil

        let description : String? = announcement.text.map(MarkdownHelper.string(for:))?.replacingOccurrences(of: "\n", with: " ")
        self.descriptionLabel.text = description
    }

}
