//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class PeerAssessmentHintViewController: UIViewController {

    private static let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var exerciseTypeLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var peerAssessmentTypeLabel: UILabel!
    @IBOutlet private weak var peerAssessmentTypeImage: UIImageView!
    @IBOutlet private weak var deadlineLabel: UILabel!
    @IBOutlet private weak var deadlineDateView: UIStackView!
    @IBOutlet private weak var instructionsView: UITextView!
    @IBOutlet private weak var launchInfoView: UIStackView!
    @IBOutlet private weak var launchButton: UIButton!
    @IBOutlet private weak var deadlineExpiredView: UIStackView!

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

        self.launchButton.layer.roundCorners(for: .default)
        self.launchButton.backgroundColor = Brand.default.colors.primary

        self.instructionsView.delegate = self
        self.instructionsView.textContainerInset = UIEdgeInsets.zero
        self.instructionsView.textContainer.lineFragmentPadding = 0

        self.updateView()
        CourseItemHelper.syncCourseItemWithContent(self.courseItem)
    }

    func updateView() {
        guard let peerAssessment = self.courseItem?.content as? PeerAssessment else { return }

        let deadlineExpired = self.courseItem?.deadline?.inPast ?? false
        self.deadlineExpiredView.isHidden = !deadlineExpired
        self.launchInfoView.isHidden = deadlineExpired

        self.titleLabel.text = courseItem.title

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

        // Set points label
        let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")
        let number = NSNumber(value: self.courseItem.maxPoints)
        self.pointsLabel.text = Self.pointsFormatter.string(from: number).flatMap { String.localizedStringWithFormat(format, $0) }

        // Set peer assessment type label and image
        switch peerAssessment.type {
        case "team":
            self.peerAssessmentTypeLabel.text = NSLocalizedString("peer-assessment-type.team", comment: "team peer assessment")
            self.peerAssessmentTypeImage.image = R.image.person3Fill()
        default:
            self.peerAssessmentTypeLabel.text = NSLocalizedString("peer-assessment-type.solo", comment: "solo peer assessment")
            self.peerAssessmentTypeImage.image = R.image.personFill()
        }

        // Set deadline label
        self.deadlineLabel.text = self.courseItem.deadline.map(Self.dateFormatter.string(from:))
        self.deadlineDateView.isHidden = self.courseItem.deadline == nil

        // Set instructions label
        if let markdown = peerAssessment.instructions {
            MarkdownHelper.attributedString(for: markdown).onSuccess { [weak self] attributedString in
                self?.instructionsView.attributedText = attributedString
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = self.courseItem else { return }
        if let typedInfo = R.segue.peerAssessmentHintViewController.openPeerAssessmentURL(segue: segue) {
            typedInfo.destination.url = item.url
        }
    }
}

extension PeerAssessmentHintViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let appNavigator = self.appNavigator else { return false }
        return !appNavigator.handle(url: URL, on: self)
    }

}

extension PeerAssessmentHintViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}