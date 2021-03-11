//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import NotificationCenter
import UIKit

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet private weak var loginRequestedLabel: UILabel!
    @IBOutlet private weak var widgetDisabledLabel: UILabel!
    @IBOutlet private weak var datesAvailableView: UIView!
    @IBOutlet private weak var todayCountLabel: UILabel!
    @IBOutlet private weak var nextCountLabel: UILabel!
    @IBOutlet private weak var allCountLabel: UILabel!

    @IBOutlet private weak var nextCourseDateContainer: UIView!
    @IBOutlet private weak var nextCourseDateCourseTitleLabel: UILabel!
    @IBOutlet private weak var nextCourseDateTitleLabel: UILabel!
    @IBOutlet private weak var nextCourseDateImageView: UIImageView!
    @IBOutlet private weak var nextCourseDateRelativeDateTimeLabel: UILabel!
    @IBOutlet private weak var nextCourseDateDateLabel: UILabel!

    @IBOutlet private weak var nextDateAvailableCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var noNextDateAvailableCenterConstraint: NSLayoutConstraint!

    private lazy var courseDateFormatter: DateFormatter = {
        return DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)
    }()

    private lazy var relativeCourseDateFormatter: DateFormatter = {
        let formatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .long)
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private var widgetIsDisabled: Bool {
        // TODO: This should be handle bei including the (currently not existing) brand framework
        return Bundle.main.bundleIdentifier?.contains("who") ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11, *) {
            // The large title font is not available on iOS 10 and the storyboard file fails to provide a suitable fallback value.
            // Therefore, we set the font to .title1 in the storyboard file and upgrade to .largeTitle for iOS 11 manually.
            let font = UIFont.preferredFont(forTextStyle: .largeTitle)
            self.todayCountLabel.font = font
            self.nextCountLabel.font = font
            self.allCountLabel.font = font
        }

        if #available(iOS 13, *) {
            self.nextCourseDateImageView.image = UIImage(named: "calendar-large")
        } else {
            self.nextCourseDateImageView.image = UIImage(named: "calendar")
        }

        self.widgetPerformUpdate { _ in }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            let isInCompactMode = self.extensionContext?.widgetActiveDisplayMode != .expanded
            self.nextDateAvailableCenterConstraint.isActive = !isInCompactMode
            self.noNextDateAvailableCenterConstraint.isActive = isInCompactMode
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let isInCompactMode = self.extensionContext?.widgetActiveDisplayMode != .expanded
        self.nextDateAvailableCenterConstraint.isActive = !isInCompactMode
        self.noNextDateAvailableCenterConstraint.isActive = isInCompactMode

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.nextCourseDateContainer.alpha = isInCompactMode ? 0 : 1
        }, completion: nil)
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let (contentChanged, nextCourseDateAvailable) = self.loadData()
        let loginStateChanged = self.updateView(nextCourseDateAvailable: nextCourseDateAvailable)
        let result: NCUpdateResult = contentChanged || loginStateChanged ? .newData : .noData
        completionHandler(result)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            // The compact view is a fixed size.
            self.preferredContentSize = maxSize
        case .expanded:
            let boundingSize = CGSize(width: maxSize.width, height: CGFloat.infinity)
            let computedSize = self.datesAvailableView.systemLayoutSizeFitting(boundingSize,
                                                                               withHorizontalFittingPriority: UILayoutPriority(rawValue: 1000),
                                                                               verticalFittingPriority: UILayoutPriority(rawValue: 10))
            self.preferredContentSize = CGSize(width: maxSize.width, height: min(computedSize.height, maxSize.height))
        @unknown default:
            preconditionFailure("Unexpected value for activeDisplayMode.")
        }
    }

    @discardableResult private func updateView(nextCourseDateAvailable: Bool) -> Bool {
        let loginStateChange = UserProfileHelper.shared.isLoggedIn != self.loginRequestedLabel.isHidden
        self.datesAvailableView.isHidden = !UserProfileHelper.shared.isLoggedIn || self.widgetIsDisabled
        self.loginRequestedLabel.isHidden = UserProfileHelper.shared.isLoggedIn || self.widgetIsDisabled
        self.widgetDisabledLabel.isHidden = !self.widgetIsDisabled
        self.extensionContext?.widgetLargestAvailableDisplayMode = nextCourseDateAvailable ? .expanded : .compact
        return loginStateChange
    }

    @discardableResult private func loadData() -> (contentChanged: Bool, nextCourseDateAvailable: Bool) {
        let oldValues = [
            self.todayCountLabel.text,
            self.nextCountLabel.text,
            self.allCountLabel.text,
            self.nextCourseDateTitleLabel.text,
        ]

        self.todayCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 1))
        self.nextCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.courseDatesForNextDays(numberOfDays: 7))
        self.allCountLabel.text = self.formattedItemCount(for: CourseDateHelper.FetchRequest.allCourseDates)

        let nextCourseDate = try? CoreDataHelper.viewContext.fetch(CourseDateHelper.FetchRequest.nextCourseDate).first

        self.nextCourseDateCourseTitleLabel.text = nextCourseDate?.course?.title
        self.nextCourseDateTitleLabel.text = nextCourseDate?.contextAwareTitle

        if #available(iOS 13, *) {
            self.nextCourseDateRelativeDateTimeLabel.text = nextCourseDate?.relativeDateTime
            self.nextCourseDateDateLabel.text = nextCourseDate?.date.map(self.courseDateFormatter.string(from:))
        } else {
            self.nextCourseDateRelativeDateTimeLabel.text = nil
            self.nextCourseDateDateLabel.text = nextCourseDate?.date.map(self.relativeCourseDateFormatter.string(from:))
        }

        let newValues = [
            self.todayCountLabel.text,
            self.nextCountLabel.text,
            self.allCountLabel.text,
            self.nextCourseDateTitleLabel.text,
        ]

        return (contentChanged: oldValues != newValues, nextCourseDateAvailable: nextCourseDate != nil)
    }

    private func formattedItemCount(for fetchRequest: NSFetchRequest<CourseDate>) -> String {
        if let count = try? CoreDataHelper.viewContext.count(for: fetchRequest) {
            return String(count)
        } else {
            return "-"
        }
    }

    @objc private func handleBackgroundTap() {
        guard let urlScheme = Bundle.main.urlScheme else { return }
        guard let url = URL(string: "\(urlScheme)://dashboard") else { return }
        self.extensionContext?.open(url, completionHandler: nil)
    }

}
