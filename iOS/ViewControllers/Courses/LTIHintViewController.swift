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
        let maxPoints = self.courseItem?.maxPoints
        let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")

        self.pointsView.text = maxPoints.flatMap({ maxPoints -> String? in
            String.localizedStringWithFormat(format, maxPoints)
        })

        guard let ltiExercise = self.courseItem?.content as? LTIExercise else { return }
        self.itemTitleLabel.text = self.courseItem?.title
        self.startButton.tintColor = Brand.default.colors.primary
        //self.startButton.titleLabel?.adjustsFontForContentSizeCategory = true
        self.instructionsView.text = ltiExercise.instructions
        //self.typeView = ltiExercise.type TODO with new API
        //LTIExercise.ExerciseType
        self.typeView.text = ltiExercise.exerciseType?.rawValue
        //self.pointsView.text = self.courseItem?.maxPoints
        //maxPoints.flatMap(String.localizedStringWithFormat(format, $0))
    }

    @IBAction private func startItem() {
        guard let item = self.courseItem else { return }

        //self.perf

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
