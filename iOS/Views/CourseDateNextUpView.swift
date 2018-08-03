//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseDateNextUpView: UIStackView {

    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    weak var delegate: CourseDateOverviewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        CourseDateOverviewCell.applyCardLook(to: self.container)
        self.courseLabel.textColor = Brand.default.colors.secondary
        self.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    func loadData() {
        if let courseDate = CoreDataHelper.viewContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value {
            self.dateLabel.text = courseDate.defaultDateString
            self.courseLabel.text = courseDate.course?.title
            self.titleLabel.text = courseDate.contextAwareTtitle
            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }

    @objc func tappedOnView() {
        if let course = CoreDataHelper.viewContext.fetchSingle(CourseDateHelper.FetchRequest.nextCourseDate).value?.course {
            self.delegate?.openCourse(course)
        }
    }

}
