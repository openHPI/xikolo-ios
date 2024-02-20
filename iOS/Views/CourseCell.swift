//
//  Created for xikolo-ios under GPL-3.0 license.
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

        var forceEmptyTeachersLabel: Bool {
            switch self {
            case .courseList:
                return false
            case .courseOverview:
                return true
            }
        }

    }

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var courseImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var teacherLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private var infoBoxes: [UIView]!

    // Configuration can be moved the Interface Builder after supporting only iOS 13 and later
    @IBOutlet private weak var languageIconView: UIImageView!
    @IBOutlet private weak var dateIconView: UIImageView!
    @IBOutlet private var visualEffectViews: [UIVisualEffectView]!
    @IBOutlet private var visualEffectVibrancyViews: [UIVisualEffectView]!

    var previewView: UIView? {
        return self.courseImage
    }

    override var isAccessibilityElement: Bool {
        get { true }
        set {}
    }

    override var accessibilityIdentifier: String? {
        get { "CourseCell" }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            let labels = [self.titleLabel, self.teacherLabel, self.dateLabel, self.languageLabel].compactMap { $0 }
            return labels.compactMap(\.accessibilityLabel).joined(separator: ", ")
        }
        set {}
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shadowView.layer.roundCorners(for: .default, masksToBounds: false)
        self.courseImage.layer.roundCorners(for: .default)
        self.infoBoxes.forEach { $0.layer.roundCorners(for: .inner) }

        self.courseImage.sd_imageTransition = .fade

        self.shadowView.addDefaultPointerInteraction()

        if #available(iOS 13, *) {
            let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .label)
            self.visualEffectViews.forEach { $0.effect = blurEffect }
            self.visualEffectVibrancyViews.forEach { $0.effect = vibrancyEffect }

            let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .caption1)
            self.languageIconView.image = UIImage(systemName: "globe", withConfiguration: symbolConfiguration)
            self.dateIconView.image = UIImage(systemName: "calendar", withConfiguration: symbolConfiguration)
        } else {
            self.languageIconView.isHidden = true
            self.dateIconView.isHidden = true
        }
    }

    func configure(_ course: Course, for configuration: Configuration) {
        self.courseImage.backgroundColor = Brand.default.colors.secondary
        self.statusView.backgroundColor = Brand.default.colors.secondary
        self.statusLabel.backgroundColor = Brand.default.colors.secondary
        self.teacherLabel.textColor = Brand.default.colors.secondary

        self.courseImage.image = nil // Avoid old images on cell reuse when new image can not be loaded
        self.courseImage.sd_setImage(with: course.imageURL, placeholderImage: nil)

        self.titleLabel.numberOfLines = configuration.showMultilineLabels ? 0 : 1
        self.teacherLabel.numberOfLines = configuration.showMultilineLabels ? 0 : 1

        self.titleLabel.text = course.title
        self.teacherLabel.text = {
            guard Brand.default.features.showCourseTeachers else { return nil }
            if course.teachers?.isEmpty ?? true, configuration.forceEmptyTeachersLabel { return " " }
            return course.teachers
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
        return 8
    }

    static func heightForCourseList(forWidth width: CGFloat, for course: Course) -> CGFloat {
        let cardWidth = width - 2 * self.cardInset
        let imageHeight = cardWidth / 2

        let titleHeight = course.title?.height(forTextStyle: .headline, boundingWidth: cardWidth) ?? 0
        let teachersHeight = course.teachers?.height(forTextStyle: .subheadline, boundingWidth: cardWidth) ?? 0

        var height = 12 + imageHeight

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
        // All values were taken from Interface Builder
        var height: CGFloat = 12 // top padding
        height += width / 2 // image
        height += self.cardBottomOffsetForOverviewList
        return height
    }

    static var cardBottomOffsetForOverviewList: CGFloat {

        var height: CGFloat = 8 // padding between image and labels
        height += UIFont.preferredFont(forTextStyle: .headline).lineHeight

        if Brand.default.features.showCourseTeachers {
            height += 4 // padding between image and text
            height += UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        }

        height += 4 // bottom padding
        return height
    }

}
