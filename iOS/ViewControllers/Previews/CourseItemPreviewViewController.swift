//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseItemPreviewViewController: UIViewController {

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

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var videoInfoView: UIView!
    @IBOutlet private weak var videoDownloadedView: UIView!
    @IBOutlet private weak var videoDownloadedLabel: UILabel!
    @IBOutlet private weak var slidesInfoView: UIView!
    @IBOutlet private weak var slidesLabel: UILabel!

    @IBOutlet private weak var exerciseInfoView: UIView!
    @IBOutlet private weak var peerAssessmentInfoView: UIView!
    @IBOutlet private weak var peerAssessmentTypeImage: UIImageView!
    @IBOutlet private weak var peerAssessmentTypeLabel: UILabel!
    @IBOutlet private weak var exerciseTypeLabel: UILabel!

    @IBOutlet private weak var pointsView: UIStackView!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var timeEffortView: UIStackView!
    @IBOutlet private weak var timeEffortLabel: UILabel!
    @IBOutlet private weak var deadlineView: UIStackView!
    @IBOutlet private weak var deadlineLabel: UILabel!

    let courseItem: CourseItem

    init?(coder: NSCoder, courseItem: CourseItem) {
        self.courseItem = courseItem
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a course item.")
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func viewDidLoad() {
        super.viewDidLoad()

        self.iconImageView.image = self.courseItem.image
        self.titleLabel.text = self.courseItem.title

        // Set points label
        let format = NSLocalizedString("course-item.max-points", comment: "maximum points for course item")
        let number = NSNumber(value: self.courseItem.maxPoints)
        self.pointsLabel.text = Self.pointsFormatter.string(from: number).flatMap { String.localizedStringWithFormat(format, $0) }
        self.pointsView.isHidden = self.courseItem.maxPoints == 0

        // Set time effort label
        let roundedTimeEffort = ceil(TimeInterval(self.courseItem.timeEffort) / 60) * 60 // round up to full minutes
        self.timeEffortLabel.text = Self.timeEffortFormatter.string(from: roundedTimeEffort)
        self.timeEffortView.isHidden = self.courseItem.timeEffort == 0

        // Set deadline label
        self.deadlineLabel.text = self.courseItem.deadline.map(Self.dateFormatter.string(from:))
        self.deadlineView.isHidden = self.courseItem.deadline == nil

        if let video = self.courseItem.content as? Video {
            self.videoInfoView.isHidden = false
            self.exerciseInfoView.isHidden = true
            self.videoDownloadedView.isHidden = StreamPersistenceManager.shared.downloadState(for: video) != .downloaded
            self.videoDownloadedLabel.text = NSLocalizedString("course-item.preview.video.downloaded",
                                                               comment: "text for downloaded video in course item preview")
            self.slidesInfoView.isHidden = video.slidesURL == nil

            if SlidesPersistenceManager.shared.downloadState(for: video) == .downloaded {
                self.slidesLabel.text = NSLocalizedString("course-item.preview.slides.downloaded",
                                                          comment: "text for downloaded slides in course item preview")
            } else {
                self.slidesLabel.text = NSLocalizedString("course-item.preview.slides.not-downloaded",
                                                          comment: "text for not downloaded slides in course item preview")
            }
        } else if self.courseItem.content is LTIExercise {
            self.videoInfoView.isHidden = true
            self.exerciseInfoView.isHidden = false
            self.peerAssessmentInfoView.isHidden = true

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
        } else if let peerAssessment = self.courseItem.content as? PeerAssessment {
            self.videoInfoView.isHidden = true
            self.exerciseInfoView.isHidden = false
            self.peerAssessmentInfoView.isHidden = false

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

            // Set peer assessment type label and image
            switch peerAssessment.type {
            case "team":
                self.peerAssessmentTypeLabel.text = NSLocalizedString("peer-assessment-type.team", comment: "team peer assessment")
                self.peerAssessmentTypeImage.image = R.image.person3Fill()
            default:
                self.peerAssessmentTypeLabel.text = NSLocalizedString("peer-assessment-type.solo", comment: "solo peer assessment")
                self.peerAssessmentTypeImage.image = R.image.personFill()
            }
        } else {
            self.videoInfoView.isHidden = true
            self.exerciseInfoView.isHidden = true
        }

        let width: CGFloat = 343
        let boundingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let fittingHeight = self.view.systemLayoutSizeFitting(boundingSize).height
        self.preferredContentSize = CGSize(width: width, height: fittingHeight)
    }

}
