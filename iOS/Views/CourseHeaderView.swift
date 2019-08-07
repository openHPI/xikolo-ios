//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class CourseHeaderView: UICollectionReusableView {

    @IBOutlet private weak var backgroundView: UIVisualEffectView!
    @IBOutlet private weak var titleView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView.layer.masksToBounds = true
        self.backgroundView.layer.cornerRadius = self.backgroundView.frame.height / 2
        self.backgroundView.backgroundColor = ColorCompatibility.systemBackground

        if #available(iOS 13, *) {
            self.backgroundView.effect = UIBlurEffect(style: .regular)
        } else {
            self.backgroundView.effect = UIBlurEffect(style: .light)
        }

        self.titleView.textColor = Brand.default.colors.secondary
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.layer.cornerRadius = self.backgroundView.frame.height / 2
    }

    func configure(_ section: NSFetchedResultsSectionInfo) {
        self.titleView.text = section.name
    }

    func configure(withText headerText: String) {
        self.titleView.text = headerText
    }

}

extension CourseHeaderView {

    static var height: CGFloat {
        let margin: CGFloat = 8
        let padding: CGFloat = 8
        return ceil(2 * margin + 2 * padding + UIFont.preferredFont(forTextStyle: .headline).lineHeight)
    }

}
