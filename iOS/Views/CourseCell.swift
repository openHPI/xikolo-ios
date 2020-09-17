//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SDWebImage
import UIKit

class CourseCell: UICollectionViewCell {

    enum Configuration {
        case courseList(configuration: CourseListConfiguration)
        case courseOverview

        var showMultilineLabels: Bool {
            switch self {
            case .courseList:
                return true
            case .courseOverview:
                return false
            }
        }

        var hideTeacherLabel: Bool {
            switch self {
            case .courseList:
                return false
            case .courseOverview:
                return true
            }
        }

        func colorWithFallback(to fallbackColor: UIColor) -> UIColor {
            if case let .courseList(configuration) = self {
                return configuration.colorWithFallback(to: fallbackColor)
            }

            return fallbackColor
        }

    }

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var courseImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var teacherLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusView: UIView!

    var previewView: UIView? {
        return self.courseImage
    }

    override var isAccessibilityElement: Bool {
        get { true }
        set {} // swiftlint:disable:this unused_setter_value
    }

    override var accessibilityIdentifier: String? {
        get { "CourseCell" }
        set {} // swiftlint:disable:this unused_setter_value
    }

    override var accessibilityLabel: String? {
        get {
            let labels = [self.titleLabel, self.teacherLabel, self.dateLabel, self.languageLabel].compactMap { $0 }
            return labels.compactMap(\.accessibilityLabel).joined(separator: ", ")
        }
        set {} // swiftlint:disable:this unused_setter_value
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shadowView.layer.roundCorners(for: .default, masksToBounds: false)
        self.courseImage.layer.roundCorners(for: .default)
        self.statusView.layer.roundCorners(for: .default)

        self.courseImage.sd_imageTransition = .fade

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientView.layer.roundCorners(for: .default)

        self.shadowView.addDefaultPointerInteraction()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.layer.sublayers?.first?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.gradientView.frame.size.height)
    }

    func configure(_ course: Course, for configuration: Configuration) {
        let accentColor = configuration.colorWithFallback(to: Brand.default.colors.secondary)

        self.courseImage.backgroundColor = accentColor
        self.statusView.backgroundColor = accentColor
        self.statusLabel.backgroundColor = accentColor
        self.teacherLabel.textColor = accentColor

        self.courseImage.image = nil // Avoid old images on cell reuse when new image can not be loaded
        self.courseImage.alpha = course.hidden ? 0.5 : 1.0
        self.gradientView.isHidden = true
        self.courseImage.sd_setImage(with: course.imageURL, placeholderImage: nil) { image, _, _, _ in
            self.gradientView.isHidden = (image == nil)
        }

        self.titleLabel.numberOfLines = configuration.showMultilineLabels ? 0 : 1
        self.teacherLabel.numberOfLines = configuration.showMultilineLabels ? 0 : 1

        self.titleLabel.text = course.title
        self.teacherLabel.text = {
            guard configuration.hideTeacherLabel else { return course.teachers }
            guard Brand.default.features.showCourseTeachers else { return course.teachers }
            guard course.teachers?.isEmpty ?? true else { return course.teachers }
            return " " // forces text into teachers label to avoid misplacement for course image
        }()
        self.teacherLabel.isHidden = !Brand.default.features.showCourseTeachers
        self.languageLabel.text = course.language.flatMap(LanguageLocalizer.nativeDisplayName(for:))
        self.dateLabel.text = CoursePeriodFormatter.string(from: course)

        self.statusView.isHidden = true
        if case let .courseList(listConfiguration) = configuration, !listConfiguration.containsOnlyEnrolledCourses {
            if let enrollment = course.enrollment {
                self.statusView.isHidden = false
                if enrollment.completed {
                    self.statusLabel.text = NSLocalizedString("course-cell.status.completed", comment: "status 'completed' of a course")
                } else {
                    self.statusLabel.text = NSLocalizedString("course-cell.status.enrolled", comment: "status 'enrolled' of a course")
                }
            }
        } else {
            if course.status == "announced" {
                self.statusView.isHidden = false
                self.statusLabel.text = NSLocalizedString("course-cell.status.upcoming", comment: "status 'upcoming' of a course")
            }
        }
    }

}

extension CourseCell {

    static func minimalWidth(for traitCollection: UITraitCollection) -> CGFloat { // swiftlint:disable:this cyclomatic_complexity
        switch traitCollection.preferredContentSizeCategory {
        case .extraSmall:
            return 280
        case .small:
            return 290
        case .medium:
            return 300
        case .large:
            return 310
        case .extraLarge:
            return 320
        case .extraExtraLarge:
            return 330
        case .extraExtraExtraLarge:
            return 340

        // Accessibility sizes
        case .accessibilityMedium:
            return 360
        case .accessibilityLarge:
            return 380
        case .accessibilityExtraLarge:
            return 400
        case .accessibilityExtraExtraLarge:
            return 420
        case .accessibilityExtraExtraExtraLarge:
            return 440

        default: // large
            return 310
        }
    }

}

extension CourseCell {

    static var cardInset: CGFloat {
        return 14
    }

    static func heightForCourseList(forWidth width: CGFloat, for course: Course) -> CGFloat {
        let cardWidth = width - 2 * self.cardInset
        let imageHeight = cardWidth / 2

        let titleHeight = course.title?.height(forTextStyle: .headline, boundingWidth: cardWidth) ?? 0
        let teachersHeight = course.teachers?.height(forTextStyle: .subheadline, boundingWidth: cardWidth) ?? 0

        var height = self.cardInset + imageHeight

        if Brand.default.features.showCourseTeachers {
            if titleHeight > 0 || teachersHeight > 0 {
                height += 8
            }

            if titleHeight > 0 && teachersHeight > 0 {
                height += 4
            }

            height += titleHeight
            height += teachersHeight
        } else {
            height += 8
            height += titleHeight
        }

        height += 5

        return height
    }

}

extension CourseCell {

    static func minimalWidthInOverviewList(for traitCollection: UITraitCollection) -> CGFloat { // swiftlint:disable:this cyclomatic_complexity
        switch traitCollection.preferredContentSizeCategory {
        case .extraSmall:
            return 260
        case .small:
            return 270
        case .medium:
            return 280
        case .large:
            return 290
        case .extraLarge:
            return 300
        case .extraExtraLarge:
            return 310
        case .extraExtraExtraLarge:
            return 320

        // Accessibility sizes
        case .accessibilityMedium:
            return 340
        case .accessibilityLarge:
            return 360
        case .accessibilityExtraLarge:
            return 380
        case .accessibilityExtraExtraLarge:
            return 400
        case .accessibilityExtraExtraExtraLarge:
            return 420

        default: // large
            return 290
        }
    }

    static func heightForOverviewList(forWidth width: CGFloat) -> CGFloat {
        var height: CGFloat = Self.cardInset
        height += width / 2 // image
        height += self.cardBottomOffsetForOverviewList
        return height
    }

    static var cardBottomOffsetForOverviewList: CGFloat {
        var height: CGFloat = 8 // padding
        height += UIFont.preferredFont(forTextStyle: .headline).lineHeight

        if Brand.default.features.showCourseTeachers {
            height += 4 // padding
            height += UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        }

        height += 4 // padding
        return height
    }

}
