//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length

import Common
import SDWebImage
import UIKit

class CourseViewController: UIViewController {

    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var cornerView: UIView!
    @IBOutlet private weak var courseAreaListContainerHeight: NSLayoutConstraint!
    @IBOutlet private weak var headerImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerImageTopSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerImageTopSafeAreaConstraint: NSLayoutConstraint!

    private var headerOffset: CGFloat = 0 {
        didSet {
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

        self.headerImageView.backgroundColor = Brand.default.colors.secondary

        self.cornerView.layer.cornerRadius = self.cornerView.frame.height / 2

        if #available(iOS 13, *) {
            self.cornerView.layer.cornerCurve = .continuous
        }

        self.cornerView.layer.shadowOpacity = 0.2
        self.cornerView.layer.shadowRadius = 8.0
        self.cornerView.layer.shadowColor = UIColor.black.cgColor

        self.titleLabel.textAlignment = self.traitCollection.horizontalSizeClass == .compact ? .natural : .center

        if self.course != nil {
            self.updateView()
        }

        self.navigationController?.delegate = self

        self.decideContent()
        self.updateHeaderConstraints()

        SpotlightHelper.shared.setUserActivity(for: self.course)
        ErrorManager.shared.remember(self.course.id, forKey: "course_id")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateCourseAreaListContainerHeight()

        self.updateHeaderConstraints()
        self.courseNavigationController?.updateNavigationBar(forProgress: self.headerOffset / self.headerHeight)

        self.titleLabel.textAlignment = self.traitCollection.horizontalSizeClass == .compact ? .natural : .center

        // Fix size of title view
        self.titleView.layoutIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let animationBlock: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            // Fix size of title view
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }

        let completionBlock: (UIViewControllerTransitionCoordinatorContext) -> Void = { [weak self] _ in
            let headerColor = self?.headerImageView.image.flatMap { self?.averageColorUnderStatusBar(withCourseVisual: $0) } ?? Brand.default.colors.secondary
            self?.courseNavigationController?.adjustToUnderlyingColor(headerColor)
        }

        coordinator.animate(alongsideTransition: animationBlock, completion: completionBlock)
    }

    func show(item: CourseItem, animated: Bool) {
        self.area = .learnings

        guard let viewController = R.storyboard.courseLearnings.courseItemViewController() else { return }
        viewController.currentItem = item

        self.navigationController?.pushViewController(viewController, animated: animated)
        self.navigationController?.navigationBar.tintColor = Brand.default.colors.window // otherwise the back button could not be visible
    }

    func show(documentLocalization: DocumentLocalization, animated: Bool) {
        self.area = .documents

        guard let url = DocumentsPersistenceManager.shared.localFileLocation(for: documentLocalization) ?? documentLocalization.fileURL else { return }

        let viewController = R.storyboard.pdfWebViewController.instantiateInitialViewController().require()
        viewController.configure(for: url, filename: documentLocalization.filename)

        self.navigationController?.pushViewController(viewController, animated: animated)
        self.navigationController?.navigationBar.tintColor = Brand.default.colors.window // otherwise the back button could not be visible
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

    private func averageColorUnderStatusBar(withCourseVisual image: UIImage?) -> UIColor? {
        let croppedImages = [
            self.croppedImageUnderNavigationBar(withCourseVisual: image, leading: true),
            self.croppedImageUnderNavigationBar(withCourseVisual: image, leading: false),
        ]

        let averageColorValues = croppedImages.compactMap(self.averageColor(of: ))

        if averageColorValues.isEmpty { return nil }

        let initialValue: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) = (0, 0, 0, 0)
        let averageColorValue = averageColorValues.reduce(initialValue) { result, value in
            return (
                red: result.red + (value.red / CGFloat(averageColorValues.count)),
                green: result.green + (value.green / CGFloat(averageColorValues.count)),
                blue: result.blue + (value.blue / CGFloat(averageColorValues.count)),
                alpha: result.alpha + (value.alpha / CGFloat(averageColorValues.count))
            )
        }

        return UIColor(red: averageColorValue.red, green: averageColorValue.green, blue: averageColorValue.blue, alpha: averageColorValue.alpha)
    }

    private func croppedImageUnderNavigationBar(withCourseVisual image: UIImage?, leading: Bool) -> CGImage? {
        guard let image = image else { return nil }

        let topInset: CGFloat
        if #available(iOS 11, *) {
            topInset = self.view.safeAreaInsets.top
        } else {
            topInset = self.view.layoutMargins.top
        }

        let imageScale = image.size.width / self.view.bounds.width
        let transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
        let xOffset = leading ? 0 : self.view.bounds.width * 0.75
        let yOffset = (image.size.height - self.headerImageView.bounds.height * imageScale) / 2 / imageScale
        let subImageRect = CGRect(x: xOffset, y: max(0, yOffset), width: self.view.bounds.width * 0.25, height: max(topInset, 44)).applying(transform)
        return image.cgImage?.cropping(to: subImageRect)
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

        self.updateContainerView()

        if updateCourseAreaSelection {
            self.courseAreaListViewController?.refresh()
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
        let activityItems = [self.course as Any]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.completionWithItemsHandler = { activityType, completed, _, _ in
            let context: [String: String?] = [
                "service": activityType?.rawValue,
                "completed": String(describing: completed),
            ]
            TrackingHelper.createEvent(.shareCourse, resourceType: .course, resourceId: self.course.id, on: self, context: context)
        }

        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    private func updateHeaderConstraints() {
        let shouldHideHeader = self.traitCollection.verticalSizeClass == .compact
        let offset = shouldHideHeader ? self.headerHeight : self.headerOffset
        self.headerImageTopSuperviewConstraint.constant = offset * -1
        self.headerImageTopSafeAreaConstraint.constant = offset * -1
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
        self.courseAreaListViewController?.refresh()
    }

}

extension CourseViewController: CourseAreaViewControllerDelegate {

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool) {
        if newlyCreated {
            self.decideContent()
        } else {
            self.courseAreaListViewController?.refresh()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only react when user interacts with the scroll view. WKWebView will trigger this when loading URLs.
        guard scrollView.isDragging else { return }

        let headerHeight = self.headerHeight
        let adjustedScrollOffset = scrollView.contentOffset.y + self.headerOffset
        var headerOffset = max(0, min(adjustedScrollOffset, headerHeight))
        headerOffset = self.traitCollection.verticalSizeClass == .compact ? headerHeight : headerOffset

        self.headerOffset = headerOffset

        if adjustedScrollOffset >= 0, // for pull to refresh
            adjustedScrollOffset <= headerHeight, // over scrolling
            self.traitCollection.verticalSizeClass != .compact {
            scrollView.contentOffset = .zero
        }

        self.courseNavigationController?.updateNavigationBar(forProgress: headerOffset / headerHeight)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate { return }
        self.snapToExtendedOrCollapsedHeaderPosition(with: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.snapToExtendedOrCollapsedHeaderPosition(with: scrollView)
    }

    private func snapToExtendedOrCollapsedHeaderPosition(with scrollView: UIScrollView) {
        let adjustedScrollOffset = scrollView.contentOffset.y + self.headerOffset
        if adjustedScrollOffset > self.headerHeight { return }

        let snapThreshold: CGFloat = 0.3
        let snapUpwards = adjustedScrollOffset / self.headerHeight > snapThreshold

        self.headerOffset = snapUpwards ? self.headerHeight : 0

        UIView.animate(withDuration: 0.25) {
            self.courseNavigationController?.updateNavigationBar(forProgress: snapUpwards ? 1 : 0)
            self.view.layoutIfNeeded()
        }
    }

}

extension CourseViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let progress: CGFloat = {
            guard viewController == self else { return 1 }

            let headerOffset = self.headerImageTopSuperviewConstraint.constant * -1
            return headerOffset / self.headerHeight
        }()

        guard let transitionController = navigationController.transitionCoordinator, animated else {
            self.courseNavigationController?.updateNavigationBar(forProgress: progress)
            return
        }

        transitionController.animate(alongsideTransition: { context in
            self.courseNavigationController?.updateNavigationBar(forProgress: progress)
            self.navigationController?.navigationBar.layoutIfNeeded()
        }, completion: { context in
            guard viewController == self else { return }

            if navigationController.viewControllers.count > 1, context.isCancelled {
                self.courseNavigationController?.updateNavigationBar(forProgress: 1)
            } else if navigationController.viewControllers.count == 1 {
                self.courseNavigationController?.updateNavigationBar(forProgress: progress)
            }
        })
    }

}
