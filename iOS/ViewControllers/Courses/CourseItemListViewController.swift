//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class CourseItemListViewController: UITableViewController {

    private static let contentToBePreloaded: [PreloadableCourseItemContent.Type] = [Video.self, RichText.self]

    private static let dateFormatter = DateFormatter.localizedFormatter(dateStyle: .long, timeStyle: .none)
    private static let timeFormatter = DateFormatter.localizedFormatter(dateStyle: .none, timeStyle: .short)

    @IBOutlet private weak var nextSectionStartLabel: UILabel!

    private var course: Course!
    private var dataSource: CoreDataTableViewDataSource<CourseItemListViewController>!

    weak var scrollDelegate: CourseAreaScrollDelegate?

    var inOfflineMode = !ReachabilityHelper.hasConnection {
        didSet {
            if oldValue != self.inOfflineMode {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // register custom section header view
        self.tableView.register(UINib(resource: R.nib.courseItemHeader), forHeaderFooterViewReuseIdentifier: R.nib.courseItemHeader.name)

        self.addRefreshControl()

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 40.0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            self.tableView.separatorInsetReference = .fromAutomaticInsets
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)

        self.setupEmptyState()
        self.updateFooterView()
        self.navigationItem.title = self.course.title

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.courseItemCell.identifier
        let request = CourseItemHelper.FetchRequest.orderedCourseItems(forCourse: course)
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "section.position") // must be the first sort descriptor
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

        self.refresh()
    }

    @objc func reachabilityChanged() {
        self.inOfflineMode = !ReachabilityHelper.hasConnection
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

        guard let footerView = tableView.tableFooterView else {
            return
        }

        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            tableView.tableFooterView = footerView
            tableView.layoutIfNeeded()
        }
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

    private func updateFooterView() {
        guard self.course.startsAt?.inPast ?? true else {
            self.nextSectionStartLabel.isHidden = true
            return
        }

        let request = CourseSectionHelper.FetchRequest.nextUnpublishedSection(for: self.course)
        guard let sectionStartDate = CoreDataHelper.viewContext.fetchSingle(request).value?.startsAt else {
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

}

extension CourseItemListViewController { // TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: trueUnlessReduceMotionEnabled)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.courseItemHeader.name) as? CourseItemHeader else {
            return nil
        }

        let indexPath = IndexPath(row: 0, section: section)
        guard let section = self.dataSource.object(at: indexPath).section else {
            return nil
        }

        header.configure(for: section, inOfflineMode: self.inOfflineMode)
        header.delegate = self

        return header
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
        }.asVoid()
    }

    func didRefresh() {
        self.updateFooterView()

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

extension CourseItemListViewController: UserActionsDelegate {

    func showAlert(with actions: [UIAlertAction], title: String?, message: String?, on anchor: UIView) {
        guard !actions.isEmpty else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = anchor
        alert.popoverPresentationController?.sourceRect = anchor.bounds.insetBy(dx: -4, dy: -4)
        alert.popoverPresentationController?.permittedArrowDirections = [.left, .right]

        for action in actions {
            alert.addAction(action)
        }

        alert.addCancelAction()

        self.present(alert, animated: trueUnlessReduceMotionEnabled)
    }

    func showAlertSpinner(title: String?, task: () -> Future<Void, XikoloError>) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        let alert = UIAlertController(spinnerTitled: title, preferredStyle: .alert)
        alert.addCancelAction { _ in
            promise.failure(.userCanceled)
        }

        self.present(alert, animated: trueUnlessReduceMotionEnabled)

        task().onComplete { result in
            promise.tryComplete(result)
            alert.dismiss(animated: trueUnlessReduceMotionEnabled)
        }

        return promise.future
    }

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
