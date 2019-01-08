//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class LTIHintViewController: UIViewController {

    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet private weak var instructionsView: UILabel!
    @IBOutlet private weak var typeView: UILabel!
    @IBOutlet private weak var pointsView: UILabel!
    @IBOutlet private weak var startButton: UIButton!

    weak var delegate: CourseItemViewController?

    private var courseItemObserver: ManagedObjectObserver?

    private var courseItem: CourseItem! {
        didSet {
            self.courseItemObserver = ManagedObjectObserver(object: self.courseItem) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateView()

        CourseItemHelper.syncCourseItemWithContent(self.courseItem)
    }

    func updateView() {
        guard let ltiExercise = self.courseItem?.content as? LTIExercise else { return }
        self.itemTitleLabel.text = self.courseItem?.title
        self.startButton.tintColor = Brand.default.colors.primary
        if let markdown = ltiExercise.instructions {
            MarkdownHelper.attributedString(for: markdown).onSuccess(DispatchQueue.main.context) { attributedString in
                self.instructionsView.attributedText = attributedString
                self.instructionsView.isHidden = false
            }
        }

        switch self.courseItem.exerciseType {
        case "main"?:
            self.typeView.text = NSLocalizedString("course.item.exercise-type.main", comment: "course item main type")
        case "bonus"?:
            self.typeView.text = NSLocalizedString("course.item.exercise-type.bonus", comment: "course item bonus type")
        case "ungraded"?:
            self.typeView.text = NSLocalizedString("course.item.exercise-type.ungraded", comment: "course item ungraded type")
        default:
            self.typeView.isHidden = true
        }

        let maxPoints = self.courseItem?.maxPoints
        let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")

        self.pointsView.text = maxPoints.flatMap({ maxPoints -> String? in
            String.localizedStringWithFormat(format, maxPoints)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = self.courseItem, let ltiExercise = item.content as? LTIExercise else { return }
        if let typedInfo = R.segue.ltiHintViewController.openLTIURL(segue: segue) {
            typedInfo.destination.url = ltiExercise.launchURL
        }
    }
}

extension LTIHintViewController: CourseItemContentViewController {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
