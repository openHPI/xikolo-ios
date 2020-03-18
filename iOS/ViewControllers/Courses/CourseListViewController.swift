//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length

import AVFoundation
import Binge
import BrightFutures
import Common
import CoreData
import UIKit

class CourseListViewController: UICollectionViewController {

    private var dataSource: CoreDataCollectionViewDataSource<CourseListViewController>!
    private var channelObserver: ManagedObjectObserver?

    @available(iOS, obsoleted: 11.0)
    private var searchController: UISearchController?

    @available(iOS, obsoleted: 11.0)
    private var statusBarBackground: UIView?

    private var filterContainerHeightConstraint: NSLayoutConstraint?
    private lazy var searchFilterViewController: CourseSearchFiltersViewController = {
        let filtersViewController = CourseSearchFiltersViewController()
        filtersViewController.delegate = self
        return filtersViewController
    }()

    var configuration: CourseListConfiguration = .allCourses

    override func viewDidLoad() {

        self.collectionView?.register(R.nib.courseCell)
        self.collectionView?.register(UINib(resource: R.nib.courseHeaderView),
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: R.nib.courseHeaderView.name)

        if case let .coursesInChannel(channel) = self.configuration {
                self.collectionView?.register(UINib(resource: R.nib.channelHeaderView),
                                              forSupplementaryViewOfKind: R.nib.channelHeaderView.name,
                                              withReuseIdentifier: R.nib.channelHeaderView.name)
                self.channelObserver = ManagedObjectObserver(object: channel) { [weak self] type in
                    guard type == .update else { return }
                    DispatchQueue.main.async {
                        if (self?.collectionView.numberOfSections ?? 0) > 0 {
                            self?.collectionView?.reloadSections(IndexSet(0..<1))
                        }
                    }
                }
            }

        if let courseListLayout = self.collectionView?.collectionViewLayout as? CardListLayout {
            courseListLayout.delegate = self
        }

        super.viewDidLoad()

        self.navigationItem.title = self.configuration.title
        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = self.configuration.largeTitleDisplayMode
        }

        self.addRefreshControl()
        self.setupEmptyState()

        let reuseIdentifier = R.reuseIdentifier.courseCell.identifier
        self.dataSource = CoreDataCollectionViewDataSource(self.collectionView,
                                                           fetchedResultsControllers: self.configuration.resultsControllers,
                                                           searchFetchRequest: self.configuration.searchFetchRequest,
                                                           cellReuseIdentifier: reuseIdentifier,
                                                           headerReuseIdentifier: R.nib.courseHeaderView.name,
                                                           delegate: self)

        self.refresh()

        self.setupSearchController()
        self.addFilterView()
    }

    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.collectionView?.preservesSuperviewLayoutMargins = true
        } else {
            searchController.searchBar.searchBarStyle = .minimal
            searchController.searchBar.isTranslucent = false
            searchController.searchBar.backgroundColor = ColorCompatibility.systemBackground
            searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            self.collectionView?.addSubview(searchController.searchBar)
            self.searchController = searchController
        }
    }

    private func addFilterView() {
        let filterContainer = UIView()
        self.collectionView.addSubview(filterContainer)

        filterContainer.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 11.0, *) {
            filterContainer.topAnchor.constraint(equalTo: self.collectionView.topAnchor).isActive = true
        } else {
            filterContainer.topAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: 44).isActive = true
        }

        filterContainer.leadingAnchor.constraint(equalTo: self.collectionView.leadingAnchor).isActive = true
        filterContainer.trailingAnchor.constraint(equalTo: self.collectionView.trailingAnchor).isActive = true
        filterContainer.widthAnchor.constraint(equalTo: self.collectionView.widthAnchor).isActive = true
        self.filterContainerHeightConstraint = filterContainer.heightAnchor.constraint(equalToConstant: 0)
        self.filterContainerHeightConstraint?.isActive = true

        filterContainer.addSubview(self.searchFilterViewController.view)
        self.searchFilterViewController.view.frame = filterContainer.frame
        self.addChild(self.searchFilterViewController)
        self.searchFilterViewController.didMove(toParent: self)
    }

    private func updateSearchFilterContainerHeight(isSearching: Bool) {
        if isSearching {
            if #available(iOS 11, *) {
                self.filterContainerHeightConstraint?.constant = CourseSearchFilterCell.cellHeight()
            } else {
                self.filterContainerHeightConstraint?.constant = ceil(CourseSearchFilterCell.cellHeight()) + 16
            }
        } else {
            self.filterContainerHeightConstraint?.constant = 0
        }
    }

    private func shareCourse(course: Course) {
        let activityItems = course
        let activityViewController = UIActivityViewController(activityItems: [activityItems], applicationActivities: nil)
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    private func showCourseDates(course: Course) {
            let courseDatesViewController = R.storyboard.courseDates.instantiateInitialViewController().require()
            courseDatesViewController.course = course
            let navigationController = XikoloNavigationController(rootViewController: courseDatesViewController)
            navigationController.navigationBar.barTintColor = ColorCompatibility.systemBackground
            self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
        }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = self.dataSource.object(at: indexPath)
        self.appNavigator?.show(course: course)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 11.0, *) {} else {
            self.collectionViewLayout.invalidateLayout()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let isSearching: Bool = {
            if #available(iOS 11, *) {
                return self.navigationItem.searchController?.isActive ?? false
            } else {
                return self.searchController?.isActive ?? false
            }
        }()
        self.updateSearchFilterContainerHeight(isSearching: isSearching)
        self.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionViewLayout.invalidateLayout()
        }
    }

    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemAt indexPath: IndexPath,
                                 point: CGPoint) -> UIContextMenuConfiguration? {
        let course = self.dataSource.object(at: indexPath)

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in

            let share = UIAction(title: NSLocalizedString("course.action-menu.share",
                                                          comment: "Title for course item share action"),
                                 image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareCourse(course: course)
            }

            let showCourseDates = UIAction(title: NSLocalizedString("course.action-menu.show-course-dates",
                                                                    comment: "Title for show course dates action"),
                                           image: UIImage(systemName: "square.and.pencil")) { _ in
                self.showCourseDates(course: course)
            }

            return UIMenu(title: "", children: [share, showCourseDates])
        }
    }

}

extension CourseListViewController: ChannelHeaderViewDelegate {

    func playChannelTeaser() {

        guard case let .coursesInChannel(channel) = self.configuration else { return }
        guard let url = channel.stageStream?.hlsURL else { return }

        let playerViewController = BingePlayerViewController()
        playerViewController.delegate = self
        playerViewController.tintColor = Brand.default.colors.window
        playerViewController.initiallyShowControls = false
        playerViewController.modalPresentationStyle = .fullScreen

        if UserDefaults.standard.playbackRate > 0 {
            playerViewController.playbackRate = UserDefaults.standard.playbackRate
        }

        playerViewController.asset = AVURLAsset(url: url)
        self.present(playerViewController, animated: trueUnlessReduceMotionEnabled) {
            playerViewController.startPlayback()
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        }
    }

}

extension CourseListViewController: BingePlayerDelegate {

    func didChangePlaybackRate(from oldRate: Float, to newRate: Float) {
        UserDefaults.standard.playbackRate = newRate
    }
}

extension CourseListViewController: CardListLayoutDelegate {

    var topInset: CGFloat {
        let filterViewHeight = self.filterContainerHeightConstraint?.constant ?? 0
        if #available(iOS 11.0, *) {
            return filterViewHeight
        } else {
            return (self.searchController?.searchBar.bounds.height ?? 0) + filterViewHeight
        }
    }

    var cardInset: CGFloat {
        return CourseCell.cardInset
    }

    var heightForHeader: CGFloat {
        guard self.configuration.shouldShowHeader || self.dataSource.isSearching else {
            return 0 // Don't show header for these configurations
        }

        return ceil(CourseHeaderView.height)
    }

    var kindForGlobalHeader: String? {
        guard case .coursesInChannel = self.configuration else { return nil }
        return R.nib.channelHeaderView.name
    }

    var heightForGlobalHeader: CGFloat {
        guard case let .coursesInChannel(channel) = self.configuration else { return 0 } // Don't show global header

        let isSearchControllerFocused = self.filterContainerHeightConstraint?.constant != 0
        if self.dataSource.isSearching || isSearchControllerFocused { return 0 } // Don't show global header

        return ChannelHeaderView.height(forWidth: collectionView.bounds.width, layoutMargins: self.view.layoutMargins, channel: channel)
    }

    func minimalCardWidth(for traitCollection: UITraitCollection) -> CGFloat {
        return CourseCell.minimalWidth(for: traitCollection)
    }

    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        if self.dataSource.isSearching && !self.dataSource.hasSearchResults {
            return 0
        }

        let course = self.dataSource.object(at: indexPath)
        return ceil(CourseCell.heightForCourseList(forWidth: boundingWidth, for: course))
    }

}

extension CourseListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let scrollOffset: CGPoint
        if #available(iOS 11.0, *) {
            scrollOffset = CGPoint(x: 0, y: (self.collectionView?.safeAreaInsets.top ?? 0) * -1.0)
        } else {
            scrollOffset = CGPoint(x: 0, y: self.topLayoutGuide.length * -1.0)
        }

        self.collectionView?.setContentOffset(scrollOffset, animated: trueUnlessReduceMotionEnabled)

        let searchText = searchController.searchBar.text
        let hasSearchText = searchText?.isEmpty == false
        let hasActiveFilters = !self.searchFilterViewController.activeFilters.isEmpty

        guard searchController.isActive, (hasSearchText || hasActiveFilters) else {
            self.dataSource.resetSearch()
            return
        }

        self.dataSource.search(withText: searchText)
    }

}

extension CourseListViewController: UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController) {
        self.collectionView?.refreshControl = nil

        if #available(iOS 11.0, *) {
            // nothing to do here
        } else {
            // on iOS 10 the search bar's backgorund will not overlap with the status bar, so we need the cover the status bar manually
            let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: UIApplication.shared.statusBarFrame.height)
            let statusBarBackground = UIView(frame: frame)
            statusBarBackground.backgroundColor = ColorCompatibility.systemBackground
            self.view.addSubview(statusBarBackground)
            statusBarBackground.autoresizingMask = [.flexibleWidth]
            self.statusBarBackground = statusBarBackground
        }

        self.updateSearchFilterContainerHeight(isSearching: true)
        self.searchFilterViewController.collectionView.reloadData()
        self.collectionViewLayout.invalidateLayout()

        // swiftlint:disable:next trailing_closure
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.collectionView.layoutIfNeeded()
        })
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.updateSearchFilterContainerHeight(isSearching: false)
        self.collectionViewLayout.invalidateLayout()

        // swiftlint:disable:next trailing_closure
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.collectionView.layoutIfNeeded()
        })
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        self.addRefreshControl()
        self.searchFilterViewController.clearFilters()

        if #available(iOS 11.0, *) {
            // nothing to do here
        } else {
            self.statusBarBackground?.removeFromSuperview()
        }
    }

}

extension CourseListViewController: CoreDataCollectionViewDataSourceDelegate {

    func configure(_ cell: CourseCell, for object: Course) {
        cell.configure(object, for: .courseList(configuration: self.configuration))
    }

    func configureHeaderView(_ headerView: CourseHeaderView, sectionInfo: NSFetchedResultsSectionInfo) {
        headerView.configure(sectionInfo, for: self.configuration)
    }

    func searchPredicate(forSearchText searchText: String) -> NSPredicate? {
        let subPredicates = searchText.split(separator: " ").map(String.init).map { searchTextPart in
            return NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "title CONTAINS[c] %@", searchTextPart),
                NSPredicate(format: "teachers CONTAINS[c] %@", searchTextPart),
                NSPredicate(format: "abstract CONTAINS[c] %@", searchTextPart),
                NSPredicate(format: "slug CONTAINS[c] %@", searchTextPart),
            ])
        }

        let searchTextPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        if self.searchFilterViewController.activeFilters.isEmpty {
            return searchTextPredicate
        }

        let filterSubpredicates = self.searchFilterViewController.activeFilters.map { filter, selectedOptions in
            return filter.predicate(forSelectedOptions: selectedOptions)
        }

        let searchFilterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterSubpredicates)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [searchTextPredicate, searchFilterPredicate])
    }

    func configureSearchHeaderView(_ searchHeaderView: CourseHeaderView, numberOfSearchResults: Int) {
        let format = NSLocalizedString("course-list.search.header", comment: "number of courses found when filtering the course list #bc-ignore!")
        searchHeaderView.configure(withText: String.localizedStringWithFormat(format, numberOfSearchResults))
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForAddtionalSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView? {
        guard kind == R.nib.channelHeaderView.name else { return nil }

        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: R.nib.channelHeaderView.name,
                                                                         for: indexPath) as? ChannelHeaderView else { return nil }

        guard case let .coursesInChannel(channel) = self.configuration else { return nil }

        view.configure(for: channel)
        view.delegate = self

        return view
    }

}

extension CourseListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        if case let .coursesInChannel(channel) = self.configuration {
            return ChannelHelper.syncChannel(channel).asVoid()
        } else {
            return CourseHelper.syncAllCourses().asVoid()
        }
    }

}

extension CourseListViewController: EmptyStateDataSource, EmptyStateDelegate {

    var emptyStateTitleText: String {
        return NSLocalizedString("empty-view.course-list.title", comment: "title for empty course list")
    }

    func didTapOnEmptyStateView() {
        self.refresh()
    }

    func setupEmptyState() {
        self.collectionView.emptyStateDataSource = self
        self.collectionView.emptyStateDelegate = self
    }

}

extension CourseListViewController: CourseSearchFiltersViewControllerDelegate {

    func didChangeFilters() {
        if #available(iOS 11, *) {
            guard let searchController = self.navigationItem.searchController else { return }
            self.updateSearchResults(for: searchController)
        } else {
            guard let searchController = self.searchController else { return }
            self.updateSearchResults(for: searchController)
        }
    }

}
