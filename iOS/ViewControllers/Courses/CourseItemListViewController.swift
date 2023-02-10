//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length

import BrightFutures
import Common
import CoreData
import UIKit

// swiftlint:disable:next type_body_length
class CourseItemListViewController: UITableViewController {

    private static let contentToBePreloaded: [PreloadableCourseItemContent.Type] = [Video.self, RichText.self]

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)
    private static let timeFormatter = DateFormatter.localizedFormatter(dateStyle: .none, timeStyle: .short)

    @IBOutlet private weak var automatedDownloadsPromotionHint: UIView!
    @IBOutlet private weak var automatedDownloadsPromotionHintExtended: UIView!
    @IBOutlet private weak var automatedDownloadsActiveHint: UIView!
    @IBOutlet private weak var automatedDownloadsActiveHintExtended: UIView!
    @IBOutlet private weak var automatedDownloadsMissingPermissionHint: UIView!

    @IBOutlet private weak var continueLearningHint: UIView!
    @IBOutlet private weak var continueLearningSectionTitleLabel: UILabel!
    @IBOutlet private weak var continueLearningItemTitleLabel: UILabel!
    @IBOutlet private weak var continueLearningItemProgressView: UIProgressView!
    @IBOutlet private weak var continueLearningItemIconView: UIImageView!
    @IBOutlet private weak var continueLearningItemIconWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var nextSectionStartLabel: UILabel!

    private var dataSource: CoreDataTableViewDataSourceWrapper<CourseItem>!

    private var courseObserver: ManagedObjectObserver?
    private var course: Course! {
        didSet {
            self.courseObserver = ManagedObjectObserver(object: self.course) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateAutomatedDownloadsHint(animated: true)
                }
            }
        }
    }

    private var lastVisitObserver: ManagedObjectObserver?
    private var lastVisit: LastVisit? {
        didSet {
            self.updateLastVisitHint()
            if let lastVisit = self.lastVisit {
                self.lastVisitObserver = ManagedObjectObserver(object: lastVisit) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.updateLastVisitHint()
                    }
                }
            } else {
                self.lastVisitObserver = nil
            }
        }
    }

    private var nextSectionStartDate: Date? {
        didSet {
            guard self.nextSectionStartDate != oldValue else { return }
            self.updateNextSectionStartHint()
        }
    }

    weak var scrollDelegate: CourseAreaScrollDelegate?

    var inOfflineMode = !ReachabilityHelper.hasConnection {
        didSet {
            if oldValue != self.inOfflineMode {
                self.tableView.reloadData()
            }
        }
    }

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        // register custom section header view
        self.tableView.register(UINib(resource: R.nib.courseItemHeader), forHeaderFooterViewReuseIdentifier: R.nib.courseItemHeader.name)

        self.addRefreshControl()

        self.adaptToTextSizeChange()

        self.tableView.separatorInsetReference = .fromAutomaticInsets
        self.tableView.dragInteractionEnabled = true
        self.tableView.dragDelegate = self

        self.continueLearningItemProgressView.tintColor = Brand.default.colors.primary
        self.continueLearningHint.layer.roundCorners(for: .default)
        self.continueLearningHint.addDefaultPointerInteraction()

        if #available(iOS 13, *) {
            let interaction = UIContextMenuInteraction(delegate: self)
            self.continueLearningHint.addInteraction(interaction)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openContinueLearningItem))
        self.continueLearningHint.addGestureRecognizer(tapGesture)

        self.automatedDownloadsPromotionHint.isHidden = true
        self.continueLearningHint.isHidden = true
        self.nextSectionStartLabel.isHidden = true

        if #available(iOS 13, *) {
            self.automatedDownloadsPromotionHint.layer.roundCorners(for: .default)
            self.automatedDownloadsPromotionHint.addDefaultPointerInteraction()

            self.automatedDownloadsActiveHint.layer.roundCorners(for: .default)
            self.automatedDownloadsActiveHint.addDefaultPointerInteraction()

            self.automatedDownloadsMissingPermissionHint.layer.roundCorners(for: .default)
            self.automatedDownloadsMissingPermissionHint.addDefaultPointerInteraction()

            let promotionTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAutomatedDownloadSettings))
            self.automatedDownloadsPromotionHint.addGestureRecognizer(promotionTapGesture)
            let activeTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAutomatedDownloadSettings))
            self.automatedDownloadsActiveHint.addGestureRecognizer(activeTapGesture)
            let missingPermissionTapGesture = UITapGestureRecognizer(target: self, action: #selector(openSettings))
            self.automatedDownloadsMissingPermissionHint.addGestureRecognizer(missingPermissionTapGesture)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adaptToTextSizeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleLastVideoProgressChangedNotification(_:)),
                                               name: LastVideoProgress.didChangeNotification,
                                               object: nil)

        self.setupEmptyState()
        self.updateAutomatedDownloadsHint(animated: false)
        self.updateLastVisit()
        self.updateNextSectionStartDate()
        self.navigationItem.title = self.course.title

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.courseItemCell.identifier
        let request = CourseItemHelper.FetchRequest.orderedCourseItems(forCourse: course)
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.position") // must be the first sort descriptor
        self.dataSource = CoreDataTableViewDataSource.dataSource(for: self.tableView,
                                                                 fetchedResultsController: resultsController,
                                                                 cellReuseIdentifier: reuseIdentifier,
                                                                 delegate: self)

        self.refresh()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.tableView.resizeTableHeaderView()
            self.tableView.resizeTableFooterView()
        }
    }

    @objc func reachabilityChanged() {
        self.inOfflineMode = !ReachabilityHelper.hasConnection
    }

    @objc private func adaptToTextSizeChange() {
        let width = UIFontMetrics.default.scaledValue(for: 28)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: width + 12, bottom: 0, right: 0)

        let value = UIFontMetrics.default.scaledValue(for: 28)
        self.continueLearningItemIconWidthConstraint.constant = value
    }

    @objc func handleLastVideoProgressChangedNotification(_ notification: Notification) {
        guard let videoId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
              let item = self.lastVisit?.item,
              let video = item.content as? Video,
              video.id == videoId else { return }

        DispatchQueue.main.async {
            self.updateLastVisitHint()
        }
    }

    func preloadCourseContent() {
        _ = Self.contentToBePreloaded.traverse { contentType in
            return contentType.preloadContent(forCourse: self.course)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? CourseItemCell else { return }
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }

        if let typeInfo = R.segue.courseItemListViewController.showCourseItem(segue: segue) {
            typeInfo.destination.currentItem = self.dataSource.object(at: indexPath)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
        self.tableView.resizeTableFooterView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDelegate?.scrollViewDidEndDecelerating(scrollView)
    }

    private func updateLastVisit() {
        let fetchRequest = LastVisitHelper.FetchRequest.lastVisit(forCourse: self.course)
        self.lastVisit = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value
    }

    private func updateLastVisitHint() {
        self.continueLearningSectionTitleLabel.text = self.lastVisit?.item?.section?.title
        self.continueLearningItemTitleLabel.text = self.lastVisit?.item?.title
        self.continueLearningItemIconView.image = self.lastVisit?.item?.image
        self.continueLearningHint.isHidden = self.lastVisit?.item == nil

        self.continueLearningItemProgressView.progress = {
            guard let video = self.lastVisit?.item?.content as? Video else { return 0 }
            guard video.duration > 0 else { return 0 }
            return Float(video.lastPosition) / Float(video.duration)
        }()

        UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
            self.tableView.resizeTableHeaderView()
        }
    }

    private func updateAutomatedDownloadsHint(animated: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let downloadSettingsExist = self.course.automatedDownloadSettings != nil
            let backgroundDownloadEnabled = self.course.automatedDownloadSettings?.newContentAction == .notificationAndBackgroundDownload
            let shouldHidePromotionHint = downloadSettingsExist || !self.course.offersNotificationsForNewContent

            let notificationsDenied = settings.authorizationStatus == .denied
            let shouldHideActiveSettingsHint = !downloadSettingsExist || notificationsDenied || !self.course.isEligibleForContentNotifications

            let shouldHideMissingPermissionHint = !(downloadSettingsExist && notificationsDenied) || !self.course.isEligibleForContentNotifications

            DispatchQueue.main.async {
                self.automatedDownloadsPromotionHint.isHidden = shouldHidePromotionHint
                self.automatedDownloadsPromotionHintExtended.isHidden = !self.course.offersAutomatedBackgroundDownloads
                self.automatedDownloadsMissingPermissionHint.isHidden = shouldHideMissingPermissionHint
                self.automatedDownloadsActiveHint.isHidden = shouldHideActiveSettingsHint
                self.automatedDownloadsActiveHintExtended.isHidden = !backgroundDownloadEnabled

                UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled(animated)) {
                    self.tableView.resizeTableHeaderView()
                }
            }
        }
    }

    private func updateNextSectionStartDate() {
        guard self.course.startsAt?.inPast ?? true else {
            self.nextSectionStartDate = nil
            return
        }

        let request = CourseSectionHelper.FetchRequest.nextUnpublishedSection(for: self.course)
        guard let date = CoreDataHelper.viewContext.fetchSingle(request).value?.startsAt else {
            self.nextSectionStartDate = nil
            return
        }

        self.nextSectionStartDate = date
    }

    private func updateNextSectionStartHint() {
        defer {
            UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
                self.tableView.resizeTableFooterView()
            }
        }

        guard let sectionStartDate = self.nextSectionStartDate else {
            self.nextSectionStartLabel.isHidden = true
            return
        }

        var dateText = Self.dateFormatter.string(from: sectionStartDate)
        dateText = dateText.replacingOccurrences(of: " ", with: "\u{00a0}") // replace spaces with non-breaking spaces

        var timeText = Self.timeFormatter.string(from: sectionStartDate)
        timeText = timeText.replacingOccurrences(of: " ", with: "\u{00a0}") // replace spaces with non-breaking spaces
        if let timeZoneAbbreviation = TimeZone.current.abbreviation() {
            timeText += " (\(timeZoneAbbreviation))"
        }

        let format = NSLocalizedString("course-item-list.footer.The next section will be available on %@ at %@",
                                       comment: "Format string for the next section start in the footer of course item list")
        self.nextSectionStartLabel.text = String(format: format, dateText, timeText)
        self.nextSectionStartLabel.isHidden = false
    }

    @objc private func openContinueLearningItem() {
        self.scrollToContinueLearningItemAndHighlight { [weak self] cell in
            self?.performSegue(withIdentifier: R.segue.courseItemListViewController.showCourseItem, sender: cell)
        }
    }

    @available(iOS 13, *)
    @objc private func showAutomatedDownloadSettings() {
        let downloadSettingsViewController = AutomatedDownloadsSettingsViewController(course: self.course)
        let navigationController = ReadableWidthNavigationController(rootViewController: downloadSettingsViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    @available(iOS 13, *)
    @objc private func openSettings() {
        Settings.open()
    }

    private func scrollToContinueLearningItemAndHighlight(completionHandler: ((UITableViewCell) -> Void)? = nil) {
        guard let item = self.lastVisit?.item else { return }
        guard let indexPath = self.dataSource.indexPath(for: item) else { return }

        self.scrollDelegate?.scrollToTop()

        UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        } completion: { _ in
            let cell = self.tableView.cellForRow(at: indexPath)
            let originalColor = cell?.backgroundColor

            _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.25, options: [.curveEaseOut], animations: {
                cell?.backgroundColor = ColorCompatibility.secondarySystemFill
            }, completion: { _ in
                _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.25, options: [.curveEaseIn], animations: {
                    cell?.backgroundColor = originalColor
                }, completion: nil)

                if let cell = cell {
                    completionHandler?(cell)
                }
            })
        }
    }

    func scroll(toSection section: CourseSection, animated: Bool) {
        guard let anyItemInSection = section.items.first else { return }
        guard let someRandomIndexPathInSection = self.dataSource.indexPath(for: anyItemInSection) else { return }
        let indexPath = IndexPath(row: 0, section: someRandomIndexPathInSection.section)

        self.scrollDelegate?.scrollToTop()

        UIView.animate(withDuration: defaultAnimationDurationUnlessReduceMotionEnabled) {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
        }
    }

}

extension CourseItemListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseItemHeader.name) as? CourseItemHeader else {
            return nil
        }

        guard let firstItemInSection = self.dataSource?.sectionInfos?[section].objects?.first as? CourseItem else {
            return nil
        }

        guard let courseSection = firstItemInSection.section else {
            return nil
        }

        header.configure(for: courseSection, delegate: self) { [weak self] in self?.inOfflineMode ?? false }

        return header
    }

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let courseItem = self.dataSource.object(at: indexPath)

        let previewProvider: UIContextMenuContentPreviewProvider = {
            return R.storyboard.courseItemPreview().instantiateInitialViewController { coder in
                return CourseItemPreviewViewController(coder: coder, courseItem: courseItem)
            }
        }

        let actionProvider: UIContextMenuActionProvider = { _ in
            let shareAction: UIAction = {
                let action = courseItem.shareAction { [weak self] in self?.shareCourseItem(at: indexPath) }
                return UIAction(action: action)
            }()

            if let video = courseItem.content as? Video {
                let downloadMenu = UIMenu(title: "", image: nil, options: .displayInline, children: video.actions.asActions())
                return UIMenu(title: "", children: [downloadMenu, shareAction])
            }

            return UIMenu(title: "", children: [shareAction])
        }

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: previewProvider, actionProvider: actionProvider)
    }

    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView,
                            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                            animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            self.performSegue(withIdentifier: R.segue.courseItemListViewController.showCourseItem, sender: cell)
        }
    }

    private func shareCourseItem(at indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        let courseItem = self.dataSource.object(at: indexPath)
        let activityViewController = UIActivityViewController(activityItems: [courseItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = cell
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

}

extension CourseItemListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: CourseItemCell, for object: CourseItem) {
        cell.delegate = self
        cell.configure(for: object)
    }

}

extension CourseItemListViewController: RefreshableViewController {

    private var preloadingWanted: Bool {
        let contentPreloadOption = UserDefaults.standard.contentPreloadSetting
        return contentPreloadOption == .always || (contentPreloadOption == .wifiOnly && ReachabilityHelper.connection == .wifi)
    }

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseSectionHelper.syncCourseSections(forCourse: self.course).flatMap { _ in
            return CourseItemHelper.syncCourseItems(forCourse: self.course)
        }.flatMap { _ in
            return LastVisitHelper.syncLastVisit(forCourse: self.course)
        }.asVoid()
    }

    func didRefresh() {
        self.updateLastVisit()
        self.updateAutomatedDownloadsHint(animated: true)
        self.updateNextSectionStartDate()

        if let course = self.course, course.isEligibleForContentNotifications {
             ExperimentAssignmentHelper.assign(
                 to: .contentNotificationsAndAutomatedDownloads,
                 inCourse: course
             ).flatMap { _ in
                 FeatureHelper.syncFeatures(forCourse: course)
             }.onSuccess { [weak self] _ in
                 self?.updateAutomatedDownloadsHint(animated: true)
             }
        }

        if #available(iOS 13, *) {
            if self.course.automatedDownloadSettings != nil {
                NewContentNotificationManager.renewNotifications(for: self.course)
                AutomatedDownloadsManager.scheduleNextBackgroundProcessingTask()
            }
        }

        if #available(iOS 15, *), let course = self.course {
            ExperimentAssignmentHelper.assign(to: .nativeQuizRecapWithNotifications, inCourse: course).flatMap { _ in
                FeatureHelper.syncFeatures(forCourse: course)
            }.onSuccess { _ in
                NotificationCenter.default.post(name: UserDefaults.quizRecapNoticedNotificationName, object: course.id)
            }.onComplete { _ in
                if FeatureHelper.hasAnyFeature([.quizRecapSectionNotifications, .quizRecapCourseEndNotification], for: course) {
                    let center = UNUserNotificationCenter.current()
                    let options: UNAuthorizationOptions = [.alert]
                    center.requestAuthorization(options: options) { _, _ in }
                }

                if FeatureHelper.hasAnyFeature([.quizRecapVersion2, .quizRecapSectionNotifications, .quizRecapCourseEndNotification], for: course) {
                    QuizRecapNotificationManager.renewNotifications(for: course)
                    QuizHelper.syncQuizzes(forCourse: course).onComplete { _ in
                        QuizRecapNotificationManager.renewNotifications(for: course)
                    }
                }
            }
        }

        guard self.preloadingWanted else { return }
        self.preloadCourseContent()
    }

}

extension CourseItemListViewController: EmptyStateDataSource, EmptyStateDelegate {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.course-content.title", comment: "title for empty course content list")
    }

    func didTapOnEmptyStateView() {
        self.refresh()
    }

    func setupEmptyState() {
        self.tableView.emptyStateDataSource = self
        self.tableView.emptyStateDelegate = self
    }

}

extension CourseItemListViewController: CourseItemCellDelegate {

    var isInOfflineMode: Bool { self.inOfflineMode }

}

extension CourseItemListViewController: CourseAreaViewController {

    var area: CourseArea {
        return .learnings
    }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate) {
        assert(area == self.area)
        self.course = course
        self.scrollDelegate = delegate
    }

}

extension CourseItemListViewController: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return [] }
        let selectedItem = self.dataSource.object(at: indexPath)
        let itemCell = tableView.cellForRow(at: indexPath) as? CourseItemCell
        return [selectedItem.dragItem(with: itemCell?.previewView)]
    }

}

@available(iOS 13, *)
extension CourseItemListViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let openActonTitle = NSLocalizedString("course-item-list.header.continue-learning.Open item",
                                               comment: "Action title to open the suggested course item to continue learning")
        let openAction = UIAction(title: openActonTitle, image: UIImage(systemName: "arrow.right.circle")) { _ in
            self.openContinueLearningItem()
        }

        let scrollActonTitle = NSLocalizedString("course-item-list.header.continue-learning.Show item in list",
                                                 comment: "Action title to scroll to the suggested course item to continue learning")
        let scrollAction = UIAction(title: scrollActonTitle, image: UIImage(systemName: "list.dash")) { _ in
            self.scrollToContinueLearningItemAndHighlight()
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [openAction, scrollAction])
        }
    }

}
