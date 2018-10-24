//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var titleView: UILabel!

    private var courseAreaViewController: UIViewController?
    private var courseAreaListViewController: CourseAreaListViewController? {
        didSet {
            self.courseAreaListViewController?.delegate = self
        }
    }

    private var courseAreaPageViewController: UIPageViewController? {
        didSet {
            self.courseAreaPageViewController?.dataSource = self
            self.courseAreaPageViewController?.delegate = self
        }
    }

    private var courseObserver: ManagedObjectObserver?

    var course: Course! {
        didSet {
            self.updateView()
            self.courseObserver = ManagedObjectObserver(object: self.course) { [weak self] type in
                guard type == .update else { return }
                DispatchQueue.main.async {
                    self?.updateView()
                }
            }
        }
    }

    var area: CourseArea?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.decideContent()

        SpotlightHelper.shared.setUserActivity(for: self.course)
        ErrorManager.shared.remember(self.course.id, forKey: "course_id")
    }

    private func updateView() {
        self.titleView.text = self.course.title

        if let titleView = self.navigationItem.titleView, let text = self.titleView.text {
            let titleWidth = NSString(string: text).size(withAttributes: [NSAttributedStringKey.font: self.titleView.font]).width
            var frame = titleView.frame
            frame.size.width = titleWidth + 2
            titleView.frame = frame
            titleView.setNeedsLayout()
        }
    }

    private func closeCourse() {
        let courseNavigationController = self.navigationController as? CourseNavigationController
        courseNavigationController?.closeCourse()
    }

    private func decideContent() {
        if !self.course.hasEnrollment {
            self.manuallyUpdate(to: .courseDetails, updateCourseAreaSelection: true)
        } else {
            let area: CourseArea = self.course.accessible ? .learnings : .courseDetails
            self.manuallyUpdate(to: area, updateCourseAreaSelection: true)
        }
    }

    private func manuallyUpdate(to area: CourseArea, updateCourseAreaSelection: Bool) {
        self.area = area

        guard self.viewIfLoaded != nil else { return }

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()

        self.updateContainerView()

        if updateCourseAreaSelection {
            self.courseAreaListViewController?.refresh(animated: true)
        }
    }

    private func updateContainerView() {
        let animationTime: TimeInterval = 0.15

        // swiftlint:disable multiple_closures_with_trailing_closure
        UIView.animate(withDuration: animationTime, delay: animationTime, options: .curveEaseIn, animations: {
            self.courseAreaViewController?.view.alpha = 0
        }) { _ in
            self.courseAreaViewController = nil

            guard let area = self.area, let newViewController = area.viewController else {
                self.courseAreaPageViewController?.setViewControllers(nil, direction: .forward, animated: false)
                return
            }

            newViewController.configure(for: self.course, with: area, delegate: self)
            newViewController.view.alpha = 0

            self.courseAreaViewController = newViewController
            self.courseAreaPageViewController?.setViewControllers([newViewController], direction: .forward, animated: false)

            // swiftlint:disable:next trailing_closure
            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations: {
                newViewController.view.alpha = 1
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseAreaListViewController = segue.destination as? CourseAreaListViewController {
            self.courseAreaListViewController = courseAreaListViewController
        } else if let courseAreaPageViewController = segue.destination as? UIPageViewController {
            self.courseAreaPageViewController = courseAreaPageViewController
        }
    }

    @IBAction private func tappedCloseButton(_ sender: Any) {
        self.closeCourse()
    }

    @IBAction private func shareCourse(_ sender: UIBarButtonItem) {
        let activityItems = ([self.course.title, self.course.url] as [Any?]).compactMap { $0 }
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            let context: [String: String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.shared.createEvent(.shareCourse, resourceType: .course, resourceId: self.course.id, context: context)
        }

        self.present(activityViewController, animated: true)
    }

}

extension CourseViewController: CourseAreaListViewControllerDelegate {

    var accessibleAreas: [CourseArea] {
        if self.course.hasEnrollment && self.course.accessible {
            return CourseArea.availableAreas
        } else {
            return CourseArea.availableAreas.filter { $0.acessibleWithoutEnrollment }
        }
    }

    var selectedArea: CourseArea? {
        return self.area
    }

    func change(to area: CourseArea) {
        self.manuallyUpdate(to: area, updateCourseAreaSelection: false)
    }

}

extension CourseViewController: UIPageViewControllerDataSource {

    private var previousAvailableArea: CourseArea? {
        let areas = self.accessibleAreas
        guard let currentArea = self.area else { return nil }
        guard let index = areas.index(of: currentArea) else { return nil }
        let indexBefore = areas.index(before: index)
        return areas[safe: indexBefore]
    }

    private var nextAvailableArea: CourseArea? {
        let areas = self.accessibleAreas
        guard let currentArea = self.area else { return nil }
        guard let index = areas.index(of: currentArea) else { return nil }
        let indexAfter = areas.index(after: index)
        return areas[safe: indexAfter]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let area = self.previousAvailableArea else { return nil }
        guard let viewController = area.viewController else { return nil }
        viewController.configure(for: self.course, with: area, delegate: self)
        return viewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let area = self.nextAvailableArea else { return nil }
        guard let viewController = area.viewController else { return nil }
        viewController.configure(for: self.course, with: area, delegate: self)
        return viewController
    }

}

extension CourseViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard finished && completed else {
            return
        }

        let currentViewControllers = self.courseAreaPageViewController?.viewControllers
        guard let currentViewController = currentViewControllers?.first, currentViewControllers?.count == 1 else {
            preconditionFailure()
        }

        guard let currentCourseAreaViewController = currentViewController as? CourseAreaViewController else {
            preconditionFailure()
        }

        self.area = currentCourseAreaViewController.area
        self.courseAreaListViewController?.refresh(animated: true)
    }

}

extension CourseViewController: CourseAreaViewControllerDelegate {

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool) {
        self.courseAreaListViewController?.reloadData()

        if newlyCreated {
            self.decideContent()
        } else {
            self.courseAreaListViewController?.refresh(animated: true)
        }
    }

}
