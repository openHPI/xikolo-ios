//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import SDWebImage
import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var courseAreaListContainerHeight: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHelperTopConstraint: NSLayoutConstraint!

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

        self.headerImageView.backgroundColor = Brand.default.colors.secondary

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .compact)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

        let tintColor = UIColor(hue: 180/255, saturation: 0, brightness: 1, alpha: 1)
        self.navigationController?.navigationBar.tintColor = tintColor

        self.navigationController?.delegate = self

        self.decideContent()

        SpotlightHelper.shared.setUserActivity(for: self.course)
        ErrorManager.shared.remember(self.course.id, forKey: "course_id")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateCourseAreaListContainerHeight()
        self.courseAreaListViewController?.reloadData()

        let shouldHideHeader = self.traitCollection.verticalSizeClass == .compact
        let headerHeight = self.headerHeightConstraint.constant
        let headerOffset = self.headerTopConstraint.constant
        self.headerTopConstraint.constant = shouldHideHeader ? headerHeight * -1 : 0
        self.headerHelperTopConstraint.constant = shouldHideHeader ? headerHeight * -1 : 0
        self.updateNavigationBar(forProgress: shouldHideHeader ? 1.0 : headerOffset/headerHeight)
    }

    func show(item: CourseItem, animated: Bool) {
        self.area = .learnings

        guard let viewController = R.storyboard.courseLearnings.courseItemViewController() else { return }
        viewController.currentItem = item

        self.navigationController?.pushViewController(viewController, animated: animated)
    }

    func show(documentLocalization: DocumentLocalization, animated: Bool) {
        self.area = .documents

        guard let url = DocumentsPersistenceManager.shared.localFileLocation(for: documentLocalization) ?? documentLocalization.fileURL else { return }

        let viewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        viewController.configure(for: url, filename: documentLocalization.filename)

        self.navigationController?.pushViewController(viewController, animated: animated)
    }

    private func updateView() {
        guard self.isViewLoaded else { return }
        self.titleView.text = self.course.title
        self.headerImageView.sd_setImage(with: self.course.imageURL)
    }

    private func updateCourseAreaListContainerHeight() {
        let containerHeight = CourseAreaCell.font(whenSelected: true).lineHeight + 2 * 8
        self.courseAreaListContainerHeight.constant = ceil(containerHeight)
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
            self.courseAreaListViewController?.refresh(animated: trueUnlessReduceMotionEnabled)
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

        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    func updateNavigationBar(forProgress progress: CGFloat) {

        var mappedProgress = max(0, min(progress, 1)) // clamping
        mappedProgress = pow(mappedProgress, 3) // ease in
        let navigationBarAlpha = min(mappedProgress, 0.995) // otherwise the bar switches to translucent

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 1
        Brand.default.colors.window.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let tintColor = UIColor(hue: hue, saturation: saturation * mappedProgress, brightness: (1 - mappedProgress * (1 - brightness)), alpha: alpha)
        self.navigationController?.navigationBar.tintColor = tintColor

        var transparentBackground: UIImage

        // The background of a navigation bar switches from being translucent to transparent when a background image is applied.
        // Below, a background image is dynamically generated with the desired opacity.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               navigationController!.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: navigationBarAlpha)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationController?.navigationBar.setBackgroundImage(transparentBackground, for: .default)
        self.navigationController?.navigationBar.setBackgroundImage(transparentBackground, for: .compact)
    }

    func addDismissalGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        self.view.addGestureRecognizer(gestureRecognizer)
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
        guard let index = areas.firstIndex(of: currentArea) else { return nil }
        let indexBefore = areas.index(before: index)
        return areas[safe: indexBefore]
    }

    private var nextAvailableArea: CourseArea? {
        let areas = self.accessibleAreas
        guard let currentArea = self.area else { return nil }
        guard let index = areas.firstIndex(of: currentArea) else { return nil }
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

        guard let currentCourseAreaViewController = self.courseAreaPageViewController?.viewControllers?.first as? CourseAreaViewController else {
            return
        }

        self.area = currentCourseAreaViewController.area
        self.courseAreaListViewController?.refresh(animated: trueUnlessReduceMotionEnabled)

        guard let previousVC = previousViewControllers.first as? CourseAreaViewController else {
            return
        }

        let insets = previousVC.courseAreaScrollView.contentInset
        currentCourseAreaViewController.courseAreaScrollView.contentInset = insets

        if currentCourseAreaViewController.courseAreaScrollView.contentOffset.y >= insets.top {
            currentCourseAreaViewController.courseAreaScrollView.contentOffset = CGPoint(x: 0, y: 0)
        }

        self.scrollViewDidScroll(currentCourseAreaViewController.courseAreaScrollView)
    }

}

extension CourseViewController: CourseAreaViewControllerDelegate {

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool) {
        self.courseAreaListViewController?.reloadData()

        if newlyCreated {
            self.decideContent()
        } else {
            self.courseAreaListViewController?.refresh(animated: trueUnlessReduceMotionEnabled)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerHeight = self.headerHeightConstraint.constant
        var headerOffset = max(0, min(scrollView.contentOffset.y + scrollView.contentInset.top, headerHeight))
        headerOffset = self.traitCollection.verticalSizeClass == .compact ? headerHeight : headerOffset

        self.headerTopConstraint.constant = headerOffset * -1
        self.headerHelperTopConstraint.constant = headerOffset * -1

        scrollView.contentInset = UIEdgeInsets(top: headerOffset, left: 0, bottom: 0, right: 0)

        if 0 <= scrollView.contentOffset.y + scrollView.contentInset.top, // for pull to refresh
            scrollView.contentOffset.y + scrollView.contentInset.top <= headerHeight, // over scrolling
            self.traitCollection.verticalSizeClass != .compact {
            scrollView.contentOffset = .zero
        }

        // update navigationbar
        self.updateNavigationBar(forProgress: headerOffset / headerHeight)
    }

    func scrollToTop(_ scrollView: UIScrollView) {
        self.headerTopConstraint.constant = 0
        self.headerHelperTopConstraint.constant = 0

        UIView.animate(withDuration: 0.25) {
            scrollView.contentInset = .zero
            scrollView.contentOffset = .zero
            self.updateNavigationBar(forProgress: 0)
            self.view.layoutIfNeeded()
        }
    }

}

extension CourseViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let progress: CGFloat = {
            guard viewController == self else { return 1 }

            let headerHeight = self.headerHeightConstraint.constant
            let headerOffset = self.headerTopConstraint.constant * -1

            return headerOffset / headerHeight
        }()

        guard let transitionController = navigationController.transitionCoordinator, animated else {
            self.updateNavigationBar(forProgress: progress)
            return
        }

        transitionController.animate(alongsideTransition: { context in
            self.updateNavigationBar(forProgress: progress)
            self.navigationController?.navigationBar.layoutIfNeeded()
        }, completion: { context in
            guard viewController == self else { return }
            guard navigationController.viewControllers.count > 1 else { return }
            guard context.isCancelled else { return }
            self.updateNavigationBar(forProgress: 1)
        })
    }

}

