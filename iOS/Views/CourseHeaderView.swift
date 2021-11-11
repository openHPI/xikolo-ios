//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseHeaderView: UICollectionReusableView {

    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var titleView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView.layer.masksToBounds = true
        self.backgroundView.layer.cornerRadius = self.backgroundView.frame.height / 2
        self.backgroundView.backgroundColor = ColorCompatibility.systemBackground
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.layer.cornerRadius = self.backgroundView.frame.height / 2
    }

    func configure(_ section: NSFetchedResultsSectionInfo, for configuration: CourseListConfiguration) {
        self.titleView.text = section.name
        self.titleView.textColor = configuration.colorWithFallback(to: Brand.default.colors.secondary)
    }

    func configure(withText headerText: String) {
        self.titleView.text = headerText
        self.titleView.textColor = Brand.default.colors.secondary
    }

}

extension CourseHeaderView {

    static var height: CGFloat {
        let topMargin: CGFloat = 8
        let padding: CGFloat = 8
        return ceil(topMargin + 2 * padding + UIFont.preferredFont(forTextStyle: .headline).lineHeight)
    }

}
