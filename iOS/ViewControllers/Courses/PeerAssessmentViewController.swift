//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class PeerAssessmentViewController: UIViewController {

    private static let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MMM yyyy"
        return formatter
    }()

    @IBOutlet private weak var peerAssessmentInfoView: UIStackView!
    @IBOutlet private weak var deadlineMessageView: UIStackView!
    @IBOutlet private weak var assessmentTitleLabel: UILabel!
    @IBOutlet private weak var assessmentTypeLabel: UILabel!
    @IBOutlet private weak var assessmentInstructionsView: UITextView!
    @IBOutlet private weak var assessmentPointsLabel: UILabel!
    @IBOutlet private weak var peerAssessmentTypeLabel: UILabel!
    @IBOutlet private weak var peerAssessmentTypeImage: UIImageView!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var redirectButton: UIButton!
    @IBOutlet private weak var teamAssessmentView: UIStackView!
    @IBOutlet private weak var soloAssessmentView: UIStackView!
    @IBOutlet private weak var deadlineLabel: UILabel!
    @IBOutlet private weak var deadlineDateView: UIStackView!

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

        var deadlineExpired = false

        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MMM yyyy"

        if let deadline = self.courseItem?.deadline {
            deadlineExpired = deadline.inPast
            self.deadlineDateView.isHidden = false
            self.deadlineLabel.text = Self.dateFormatter.string(from: deadline)
        }

        self.deadlineMessageView.isHidden = !deadlineExpired
        self.peerAssessmentInfoView.isHidden = deadlineExpired

        self.redirectButton.layer.roundCorners(for: .default)
        self.redirectButton.backgroundColor = Brand.default.colors.primary

        self.updateView()
        CourseItemHelper.syncCourseItemWithContent(self.courseItem)
    }

    func updateView() {
        guard let peerAssessment = self.courseItem?.content as? PeerAssessment else { return }

        self.assessmentTitleLabel.text = courseItem.title

        switch self.courseItem.exerciseType {
        case "main":
            self.assessmentTypeLabel.text = NSLocalizedString("course.item.exercise-type.disclaimer.main", comment: "course item main type")
        case "bonus":
            self.assessmentTypeLabel.text = NSLocalizedString("course.item.exercise-type.disclaimer.bonus", comment: "course item bonus type")
        case "selftest":
            self.assessmentTypeLabel.text = NSLocalizedString("course.item.exercise-type.disclaimer.ungraded", comment: "course item ungraded type")
        default:
            self.assessmentTypeLabel.isHidden = true
        }

        let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")
        let number = NSNumber(value: self.courseItem.maxPoints)
        self.assessmentPointsLabel.text = Self.pointsFormatter.string(from: number).flatMap { String.localizedStringWithFormat(format, $0) }

        switch peerAssessment.type {
        case "team":
            self.peerAssessmentTypeLabel.text = "Team Peer Assessment"
            self.teamAssessmentView.isHidden = false
            self.soloAssessmentView.isHidden = true
        default:
            self.peerAssessmentTypeLabel.text = "Peer Assessment"
            self.teamAssessmentView.isHidden = true
            self.soloAssessmentView.isHidden = false
        }

        self.assessmentInstructionsView.text = peerAssessment.instructions
        if let markdown = peerAssessment.instructions {
            MarkdownHelper.attributedString(for: markdown).onSuccess { [weak self] attributedString in
                self?.assessmentInstructionsView.attributedText = attributedString
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = self.courseItem else { return }
        if let typedInfo = R.segue.iOSPeerAssessmentViewController.openPeerAssessmentURL(segue: segue) {
            typedInfo.destination.url = item.url
               }
    }
}

extension PeerAssessmentViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
