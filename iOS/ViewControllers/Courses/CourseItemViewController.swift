//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import UIKit

import CoreData

class CourseItemViewController: UIPageViewController {

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        return label
    }()

    private var previousItem: CourseItem?
    private var nextItem: CourseItem?

    var currentItem: CourseItem? {
        didSet {
            self.trackItemVisit()
            ErrorManager.shared.remember(self.currentItem?.id as Any, forKey: "item_id")

            self.previousItem = self.currentItem?.previousItem
            self.nextItem = self.currentItem?.nextItem

            self.navigationItem.rightBarButtonItem = self.generateActionMenuButton()
            self.updateProgressLabel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self

        self.navigationItem.rightBarButtonItem = self.generateActionMenuButton()

        self.view.backgroundColor = ColorCompatibility.systemBackground
        self.navigationItem.titleView = self.progressLabel

        guard let item = self.currentItem else { return }
        guard let newViewController = self.viewController(for: item) else { return }
        self.setViewControllers([newViewController], direction: .forward, animated: false)
    }

    func reload(animated: Bool) {
        guard let item = self.currentItem else { return }
        guard let newViewController = self.viewController(for: item) else { return }
        self.setViewControllers([newViewController], direction: .forward, animated: animated)
    }

    private func viewController(for item: CourseItem) -> CourseItemContentViewController? {
        guard !item.isProctoredInProctoredCourse else {
            let viewController = R.storyboard.courseLearningsProctored.instantiateInitialViewController()
            viewController?.configure(for: item)
            return viewController
        }

        guard item.hasAvailableContent else {
            let viewController = R.storyboard.courseLearningsUnavailable.instantiateInitialViewController()
            viewController?.configure(for: item)
            viewController?.delegate = self
            return viewController
        }

        let viewController: CourseItemContentViewController? = {
            switch item.contentType {
            case "video":
                return R.storyboard.courseLearningsVideo.instantiateInitialViewController()
            case "rich_text":
                return R.storyboard.courseLearningsRichtext.instantiateInitialViewController()
            case "lti_exercise":
                return R.storyboard.courseLearningsLTI.instantiateInitialViewController()
            case "peer_assessment":
                return R.storyboard.courseLearningsPeerAssessment.instantiateInitialViewController()
            default:
                return R.storyboard.courseLearningsWeb.instantiateInitialViewController()
            }
        }()

        viewController?.configure(for: item)
        return viewController
    }

    private func trackItemVisit() {
        guard let item = self.currentItem else { return }
        guard !item.isProctoredInProctoredCourse else { return }
        guard item.hasAvailableContent else { return }

        CourseItemHelper.markAsVisited(item)
        LastVisitHelper.recordVisit(for: item)

        let context = [
            "content_type": item.contentType,
            "section_id": item.section?.id,
            "course_id": item.section?.course?.id,
        ]
        TrackingHelper.createEvent(.visitedItem, resourceType: .item, resourceId: item.id, on: self, context: context)
    }

    private func generateActionMenuButton() -> UIBarButtonItem {
        var menuActions: [[Action]] = []

        if let video = self.currentItem?.content as? Video {
            menuActions += [video.actions]
        }

        menuActions.append([
            self.currentItem?.shareAction { [weak self] in self?.shareCourseItem() },
            self.currentItem?.openHelpdesk { [weak self] in self?.openHelpdesk() },
        ].compactMap { $0 })

        let button = UIBarButtonItem.circularItem(
            with: R.image.navigationBarIcons.dots(),
            target: self,
            menuActions: menuActions
        )

        button.isEnabled = true
        button.accessibilityLabel = NSLocalizedString(
            "accessibility-label.course-item.navigation-bar.item.actions",
            comment: "Accessibility label for actions button in navigation bar of the course item view"
        )
        return button
    }

    private func updateProgressLabel() {
        if let item = self.currentItem, let section = item.section {
            let sortedCourseItems = section.items.sorted(by: \.position)

            if let index = sortedCourseItems.firstIndex(of: item) {
                self.progressLabel.text = "\(index + 1) / \(section.items.count)"
                self.progressLabel.sizeToFit()
            } else {
                self.progressLabel.text = "- / \(section.items.count)"
                self.progressLabel.sizeToFit()
            }
        } else {
            self.progressLabel.text = nil
        }
    }

    private func shareCourseItem() {
        guard let item = self.currentItem else { return }
        let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    private func openHelpdesk() {
        let helpdeskViewController = R.storyboard.tabAccount.helpdeskViewController().require()
        helpdeskViewController.course = self.currentItem?.section?.course
        let navigationController = CustomWidthNavigationController(rootViewController: helpdeskViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

}

extension CourseItemViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let item = self.previousItem else { return nil }
        guard let newViewController = self.viewController(for: item) else { return nil }
        return newViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let item = self.nextItem else { return nil }
        guard let newViewController = self.viewController(for: item) else { return nil }
        return newViewController
    }

}

extension CourseItemViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard finished && completed else {
            return
        }

        guard let currentCourseItemContentViewController = self.viewControllers?.first as? CourseItemContentViewController else {
            return
        }

        self.currentItem = currentCourseItemContentViewController.item
    }

}
