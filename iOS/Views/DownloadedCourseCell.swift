//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DownloadedCourseCell: UITableViewCell {

    @IBOutlet weak var titleView: UILabel!

    func configure(for course: Course) {
        self.titleView.text = course.title
    }

}
