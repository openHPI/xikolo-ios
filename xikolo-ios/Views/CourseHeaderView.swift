//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseHeaderView: UICollectionReusableView {

    @IBOutlet private weak var backgroundView: UIVisualEffectView!
    @IBOutlet private weak var titleView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView.layer.masksToBounds = true
        self.backgroundView.layer.cornerRadius = 17.0
        self.backgroundView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        self.titleView.textColor = Brand.TintColorSecond
    }

    func configure(_ section: NSFetchedResultsSectionInfo) {
        self.titleView.text = section.name
    }

    func configure(withText headerText: String) {
        self.titleView.text = headerText
    }

}
