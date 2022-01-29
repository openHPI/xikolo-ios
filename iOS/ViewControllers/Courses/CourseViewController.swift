//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length type_body_length

import Common
import SDWebImage
import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var cardHeaderView: UIView!
    @IBOutlet private weak var cornerView: UIView!
    @IBOutlet private weak var courseAreaListContainerHeight: NSLayoutConstraint!
    @IBOutlet private weak var headerImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerImageTopSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerImageTopSafeAreaConstraint: NSLayoutConstraint!

    private var headerOffset: CGFloat = 0 {
        didSet {
            guard self.headerOffset != oldValue else { return }
            self.updateHeaderConstraints()
        }
    }

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

    private var headerHeight: CGFloat {
        return self.headerImageHeightConstraint.constant + self.titleView.frame.height
    }

    private var courseNavigationController: CourseNavigationController? {
        return self.navigationController as? CourseNavigationController
    }

    private lazy var closeButton: UIBarButtonItem = {
        let action = Action(title: "", image: nil) { [weak self] in self?.closeCourse() }
        let item = UIBarButtonItem.circularItem(with: R.image.navigationBarIcons.xmark(), target: self, primaryAction: action)

        item.accessibilityLabel = NSLocalizedString(
            "accessibility-label.course.navigation-bar.item.close",
            comment: "Accessibility label for close button in navigation bar of the course card view"
        )

        return item
    }()

    private lazy var actionMenuButton: UIBarButtonItem = self.makeActionsButton()

    private var downUpwardsInitialHeaderOffset: CGFloat = 0
    private lazy var downUpwardsGestureRecognizer: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        panGesture.delegate = self
        return panGesture
    }()

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

    var area: CourseArea = .learnings

    override var toolbarItems: [UIBarButtonItem]? {
        get {
            return self.courseAreaPageViewController?.viewControllers?.first?.toolbarItems
        }
        // we only want to use the toolbar items of the embedded view controllers
        // swiftlint:disable:next unused_setter_value
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.closeButton
        self.navigationItem.rightBarButtonItem = self.actionMenuButton
        self.headerImageView.backgroundColor = Brand.default.colors.secondary
        self.headerImageView.sd_imageTransition = .fade

        self.cornerView.layer.cornerRadius = self.cornerView.frame.height / 2

        if #available(iOS 13, *) {
            self.cornerView.layer.cornerCurve = .continuous
        }

        self.cornerView.layer.shadowOpacity = 0.2
        self.cornerView.layer.shadowRadius = 8.0
        self.cornerView.layer.shadowColor = UIColor.black.cgColor

        self.titleLabel.textAlignment = self.traitCollection.horizontalSizeClass == .compact ? .natural : .center

        self.navigationController?.delegate = self

        self.updateView()
        self.transitionIfPossible(to: self.area)
        self.updateHeaderConstraints()

        SpotlightHelper.shared.setUserActivity(for: self.course)
        ErrorManager.shared.remember(self.course.id, forKey: "course_id")

        self.cardHeaderView.addGestureRecognizer(self.downUpwardsGestureRecognizer)

        FeatureHelper.syncFeatures(forCourse: self.course).onSuccess { [weak self] in
            self?.courseAreaListViewController?.refresh()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.updateHeaderConstraints()
        self.courseNavigationController?.updateNavigationBar(forProgress: self.headerOffset / self.headerHeight)

        self.titleLabel.textAlignment = self.traitCollection.horizontalSizeClass == .compact ? .natural : .center

        // Fix size of title view
        self.titleView.layoutIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let animationBlock: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            self?.updateHeaderConstraints()
            // Fix size of title view
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }

        let completionBlock: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            let headerColor = self?.headerImageView.image.flatMap { self?.averageColorUnderStatusBar(withCourseVisual: $0) } ?? Brand.default.colors.secondary
            self?.courseNavigationController?.adjustToUnderlyingColor(headerColor)

            if let headerOffset = self?.headerOffset {
                self?.snapToExtendedOrCollapsedHeaderPosition(with: headerOffset)
            }
        }

        coordinator.animate(alongsideTransition: animationBlock, completion: completionBlock)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container is CourseAreaListViewController {
            self.courseAreaListContainerHeight?.constant = container.preferredContentSize.height
        }
    }

    func show(item: CourseItem, animated: Bool) {
        self.transitionIfPossible(to: .learnings)

        guard let viewController = R.storyboard.courseLearnings.courseItemViewController() else { return }
        viewController.currentItem = item

        self.courseNavigationController?.updateNavigationBar(forProgress: 1)
        self.show(viewController, sender: self)
    }

    func show(documentLocalization: DocumentLocalization, animated: Bool) {
        self.transitionIfPossible(to: .documents)

        guard let url = DocumentsPersistenceManager.shared.localFileLocation(for: documentLocalization) ?? documentLocalization.fileURL else { return }

        let viewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        viewController.configure(for: url, filename: documentLocalization.filename)

        self.courseNavigationController?.updateNavigationBar(forProgress: 1)
        self.show(viewController, sender: self)
    }

    private func updateView() {
        guard self.isViewLoaded else { return }
        self.navigationItem.title = self.course.title
        self.titleLabel.text = self.course.title
        self.headerImageView.sd_setImage(with: self.course.imageURL) { [weak self] image, _, _, _ in
            let headerColor = self?.averageColorUnderStatusBar(withCourseVisual: image) ?? Brand.default.colors.secondary
            self?.courseNavigationController?.adjustToUnderlyingColor(headerColor)
        }
    }

    private func makeActionsButton() -> UIBarButtonItem {
        let menuActions = [
            self.course?.shareAction { [weak self] in self?.shareCourse() },
            self.course?.showCourseDatesAction { [weak self] in self?.showCourseDates() },
            self.course?.openHelpdeskAction { [weak self] in self?.openHelpdesk() },
            self.course?.automatedDownloadAction { [weak self] in self?.openAutomatedDownloadSettings() },
        ].compactMap { $0 }

        let item = UIBarButtonItem.circularItem(
            with: R.image.navigationBarIcons.dots(),
            target: self,
            menuActions: [menuActions]
        )

        item.accessibilityLabel = NSLocalizedString(
            "accessibility-label.course.navigation-bar.item.actions",
            comment: "Accessibility label for actions button in navigation bar of the course card view"
        )

        return item
    }

    private func averageColorUnderStatusBar(withCourseVisual image: UIImage?) -> UIColor? {
        let croppedImage = self.croppedImageUnderStatusBar(withCourseVisual: image)
        guard let averageColorValue = self.averageColor(of: croppedImage) else { return nil }
        return UIColor(red: averageColorValue.red, green: averageColorValue.green, blue: averageColorValue.blue, alpha: averageColorValue.alpha)
    }

    private func croppedImageUnderStatusBar(withCourseVisual image: UIImage?) -> CGImage? {
        guard let image = image else { return nil }

        let imageScale = image.size.width / self.view.bounds.width
        let transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
        let yOffset = (image.size.height - self.headerImageView.bounds.height * imageScale) / 2 / imageScale

        let statusBarHeight: CGFloat = {
            if #available(iOS 13, *) {
                return self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 12
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }()

        let subImageRect = CGRect(x: 0, y: max(0, yOffset), width: self.view.bounds.width, height: statusBarHeight)
        return image.cgImage?.cropping(to: subImageRect.applying(transform))
    }

    // swiftlint:disable:next large_tuple
    private func averageColor(of image: CGImage?) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let image = image else { return nil }

        // inspired by https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
        let inputImage = CIImage(cgImage: image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return (red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }

    func transitionIfPossible(to area: CourseArea) {
        if self.course.hasEnrollment {
            let newArea = self.course.accessible ? area : .courseDetails
            self.manuallyUpdate(to: newArea, updateCourseAreaSelection: true)
        } else {
            self.manuallyUpdate(to: .courseDetails, updateCourseAreaSelection: true)
        }
    }

    private func manuallyUpdate(to area: CourseArea, updateCourseAreaSelection: Bool) {
        self.area = area

        guard self.viewIfLoaded != nil else { return }

        self.updateContainerView()

        if updateCourseAreaSelection {
            self.courseAreaListViewController?.refresh()
        }
    }

    private func updateContainerView() {
        let animationTime: TimeInterval = 0.15

        UIView.animate(withDuration: animationTime, delay: animationTime, options: .curveEaseIn) {
            self.courseAreaViewController?.view.alpha = 0
        } completion: { _ in
            self.courseAreaViewController = nil

            guard let newViewController = self.area.viewController else {
                self.courseAreaPageViewController?.setViewControllers(nil, direction: .forward, animated: false)
                return
            }

            newViewController.configure(for: self.course, with: self.area, delegate: self)
            newViewController.view.alpha = 0

            self.courseAreaViewController = newViewController
            self.courseAreaPageViewController?.setViewControllers([newViewController], direction: .forward, animated: false)

            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut) {
                newViewController.view.alpha = 1
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseAreaListViewController = segue.destination as? CourseAreaListViewController {
            self.courseAreaListViewController = courseAreaListViewController
        } else if let courseAreaPageViewController = segue.destination as? UIPageViewController {
            self.courseAreaPageViewController = courseAreaPageViewController
        }
    }

    @objc private func closeCourse() {
        let courseNavigationController = self.navigationController as? CourseNavigationController
        courseNavigationController?.closeCourse()
    }

    private func showCourseDates() {
        let courseDatesViewController = R.storyboard.courseDates.instantiateInitialViewController().require()
        courseDatesViewController.course = course
        let navigationController = CustomWidthNavigationController(rootViewController: courseDatesViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    private func shareCourse() {
        let activityViewController = UIActivityViewController.make(for: course, on: self)
        activityViewController.popoverPresentationController?.barButtonItem = self.actionMenuButton
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    private func openHelpdesk() {
        let helpdeskViewController = R.storyboard.tabAccount.helpdeskViewController().require()
        helpdeskViewController.course = self.course
        let navigationController = ReadableWidthNavigationController(rootViewController: helpdeskViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    private func openAutomatedDownloadSettings() {
        guard #available(iOS 13, *), let course = self.course else { return }
        let downloadSettingsViewController = AutomatedDownloadsSettingsViewController(course: course)
        let navigationController = ReadableWidthNavigationController(rootViewController: downloadSettingsViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    private func updateHeaderConstraints() {
        let shouldHideHeader = self.traitCollection.verticalSizeClass == .compact
        let offset = shouldHideHeader ? self.headerHeight : self.headerOffset
        self.headerImageTopSuperviewConstraint.constant = offset * -1
        self.headerImageTopSafeAreaConstraint.constant = offset * -1
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let headerOffset = -1 * gestureRecognizer.translation(in: self.view).y + self.downUpwardsInitialHeaderOffset

        switch gestureRecognizer.state {
        case .began:
            self.downUpwardsInitialHeaderOffset = self.headerOffset
        case .changed:
            self.adjustHeaderPosition(for: headerOffset)
        case .ended:
            self.snapToExtendedOrCollapsedHeaderPosition(with: headerOffset)
        default:
            break
        }
    }

}

extension CourseViewController: CourseAreaListViewControllerDelegate {

    var accessibleAreas: [CourseArea] {
        if self.course.external {
            return [.courseDetails]
        } else if self.course.hasEnrollment && self.course.accessible {
            return CourseArea.availableAreas(in: self.course)
        } else {
            return CourseArea.availableAreas(in: self.course).filter(\.accessibleWithoutEnrollment)
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
        guard let index = areas.firstIndex(of: self.area) else { return nil }
        let indexBefore = areas.index(before: index)
        return areas[safe: indexBefore]
    }

    private var nextAvailableArea: CourseArea? {
        let areas = self.accessibleAreas
        guard let index = areas.firstIndex(of: self.area) else { return nil }
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
        self.courseAreaListViewController?.refresh()
    }

}

extension CourseViewController: CourseAreaViewControllerDelegate {

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool) {
        self.actionMenuButton = self.makeActionsButton()
        self.navigationItem.rightBarButtonItem = self.actionMenuButton

        if newlyCreated {
            self.transitionIfPossible(to: .learnings)
        } else {
            self.courseAreaListViewController?.refresh()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only react when user interacts with the scroll view. WKWebView will trigger this when loading URLs.
        guard scrollView.isDragging else { return }

        let adjustedScrollOffset = scrollView.contentOffset.y + self.headerOffset
        self.adjustHeaderPosition(for: adjustedScrollOffset)

        if adjustedScrollOffset >= 0, // for pull to refresh
            adjustedScrollOffset <= self.headerHeight, // over scrolling
            self.traitCollection.verticalSizeClass != .compact {
            scrollView.contentOffset = .zero
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate { return }
        self.snapToExtendedOrCollapsedHeaderPosition(with: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.snapToExtendedOrCollapsedHeaderPosition(with: scrollView)
    }

    func scrollToTop() {
        let headerOffset: CGFloat = self.headerHeight
        snapToExtendedOrCollapsedHeaderPosition(with: headerOffset)
    }

    private func adjustHeaderPosition(for scrollOffset: CGFloat) {
        let headerHeight = self.headerHeight
        var headerOffset = max(0, min(scrollOffset, headerHeight))
        headerOffset = self.traitCollection.verticalSizeClass == .compact ? headerHeight : headerOffset

        self.headerOffset = headerOffset
        self.courseNavigationController?.updateNavigationBar(forProgress: headerOffset / headerHeight)
    }

    private func snapToExtendedOrCollapsedHeaderPosition(with scrollView: UIScrollView) {
        let adjustedScrollOffset = scrollView.contentOffset.y + self.headerOffset
        if adjustedScrollOffset > self.headerHeight { return }
        self.snapToExtendedOrCollapsedHeaderPosition(with: adjustedScrollOffset)
    }

    private func snapToExtendedOrCollapsedHeaderPosition(with headerOffset: CGFloat) {
        let snapThreshold: CGFloat = 0.3
        let snapUpwards = headerOffset / self.headerHeight > snapThreshold

        self.headerOffset = snapUpwards ? self.headerHeight : 0

        UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
            self.courseNavigationController?.updateNavigationBar(forProgress: snapUpwards ? 1 : 0)
            self.view.layoutIfNeeded()
        }
    }

}

extension CourseViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController == self else {
            navigationController.transitionCoordinator?.animate { _ in
                self.courseNavigationController?.updateNavigationBarTintColor(forMappedProgress: 1)
            }

            return
        }

        let headerOffset = self.headerImageTopSuperviewConstraint.constant * -1
        let progress = headerOffset / self.headerHeight

        guard let transitionCoordinator = navigationController.transitionCoordinator, animated else {
            self.courseNavigationController?.updateNavigationBar(forProgress: progress)
            return
        }

        transitionCoordinator.animate { _ in
            self.courseNavigationController?.updateNavigationBar(forProgress: progress)
            self.navigationController?.navigationBar.layoutIfNeeded()
        } completion: { context in
            guard viewController == self else { return }

            if navigationController.viewControllers.count > 1, context.isCancelled {
                self.courseNavigationController?.updateNavigationBar(forProgress: 1)
            } else if navigationController.viewControllers.count == 1 {
                self.courseNavigationController?.updateNavigationBar(forProgress: progress)
            }
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self { return }
        self.courseNavigationController?.updateNavigationBar(forProgress: 1)
    }

}

extension CourseViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard self.headerOffset != self.headerHeight else { return false }
        return otherGestureRecognizer == self.courseNavigationController?.dismissalGestureRecognizer
    }

}
