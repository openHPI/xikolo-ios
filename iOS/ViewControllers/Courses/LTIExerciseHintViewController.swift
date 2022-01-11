//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class LTIExerciseHintViewController: UIViewController {

    private static let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static let timeEffortFormatter: DateComponentsFormatter = {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = Locale.autoupdatingCurrent
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)

    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet private weak var metaDataView: UIView!

    @IBOutlet private weak var exerciseTypeLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var timeEffortView: UIView!
    @IBOutlet private weak var timeEffortLabel: UILabel!
    @IBOutlet private weak var deadlineDateView: UIView!
    @IBOutlet private weak var deadlineLabel: UILabel!
    @IBOutlet private weak var instructionsView: UITextView!

    @IBOutlet private weak var launchExerciseView: UIStackView!
    @IBOutlet private weak var loadingScreen: UIView!
    @IBOutlet private weak var loadingScreenHeight: NSLayoutConstraint!
    @IBOutlet private weak var launchButton: UIButton!

    @IBOutlet private weak var notAvailableView: UIView!

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

        self.itemTitleLabel.text = self.courseItem?.title
        self.launchExerciseView.isHidden = true
        self.loadingScreen.isHidden = false
        self.notAvailableView.isHidden = true

        self.launchButton.layer.roundCorners(for: .default)
        self.launchButton.backgroundColor = Brand.default.colors.primary

        self.instructionsView.delegate = self
        self.instructionsView.textContainerInset = UIEdgeInsets.zero
        self.instructionsView.textContainer.lineFragmentPadding = 0

        self.notAvailableView.layer.roundCorners(for: .default)

        self.updateView()
        CourseItemHelper.syncCourseItemWithContent(self.courseItem)
    }

    func updateView() {
        // Set points label
        let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")
        let number = NSNumber(value: self.courseItem.maxPoints)
        self.pointsLabel.text = Self.pointsFormatter.string(from: number).flatMap { String.localizedStringWithFormat(format, $0) }

        // Set time effort label
        let roundedTimeEffort = ceil(TimeInterval(self.courseItem.timeEffort) / 60) * 60 // round up to full minutes
        self.timeEffortLabel.text = Self.timeEffortFormatter.string(from: roundedTimeEffort)
        self.timeEffortView.isHidden = self.courseItem.timeEffort == 0

        // Set deadline label
        self.deadlineLabel.text = self.courseItem.deadline.map(Self.dateFormatter.string(from:))
        self.deadlineDateView.isHidden = self.courseItem.deadline == nil

        // Set exercise type label
        switch self.courseItem.exerciseType {
        case "main":
            self.exerciseTypeLabel.text = NSLocalizedString("course.item.exercise-type.disclaimer.main", comment: "course item main type")
        case "bonus":
            self.exerciseTypeLabel.text = NSLocalizedString("course.item.exercise-type.disclaimer.bonus", comment: "course item bonus type")
        case "selftest":
            self.exerciseTypeLabel.text = NSLocalizedString("course.item.exercise-type.disclaimer.ungraded", comment: "course item ungraded type")
        default:
            self.exerciseTypeLabel.text = nil
        }

        guard let ltiExercise = self.courseItem?.content as? LTIExercise,
              ltiExercise.launchURL != nil else {
            self.loadingScreen.isHidden = true
            self.launchExerciseView.isHidden = true
            self.notAvailableView.isHidden = false
            return
        }

        self.instructionsView.setMarkdownWithImages(from: ltiExercise.instructions)
        self.loadingScreen.isHidden = true
        self.launchExerciseView.isHidden = false
        self.notAvailableView.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = self.courseItem, let ltiExercise = item.content as? LTIExercise else { return }
        if let typedInfo = R.segue.ltiExerciseHintViewController.openLTIURL(segue: segue) {
            typedInfo.destination.url = ltiExercise.launchURL
        }
    }

    override func viewWillLayoutSubviews() {
        self.view.layoutSubviews()
        self.loadingScreenHeight.constant = self.view.bounds.height - self.metaDataView.bounds.height
    }
}

extension LTIExerciseHintViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let appNavigator = self.appNavigator else { return false }
        return !appNavigator.handle(url: URL, on: self)
    }

}

extension LTIExerciseHintViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
