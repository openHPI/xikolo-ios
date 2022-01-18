//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable file_length

import AVFoundation
import Binge
import BrightFutures
import Common
import CoreData
import UIKit

class CourseListViewController: CustomWidthCollectionViewController {

    private var dataSource: CoreDataCollectionViewDataSource<CourseListViewController>!
    private var relationshipKeyPathsObserver: RelationshipKeyPathsObserver<Course>?

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

        if case .coursesInChannel = self.configuration {
            self.collectionView?.register(UINib(resource: R.nib.channelHeaderView),
                                          forSupplementaryViewOfKind: R.nib.channelHeaderView.name,
                                          withReuseIdentifier: R.nib.channelHeaderView.name)
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
        self.relationshipKeyPathsObserver = RelationshipKeyPathsObserver(for: Course.self, managedObjectContext: CoreDataHelper.viewContext, keyPaths: [
            #keyPath(Course.enrollment),
            #keyPath(Course.channel),
        ])

        self.refresh()

        self.setupSearchController()
        self.addFilterView()

        if #available(iOS 11.0, *) {
            self.collectionView.dragDelegate = self
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container is CourseSearchFiltersViewController {
            let isSearching: Bool = {
                if #available(iOS 11, *) {
                    return self.navigationItem.searchController?.isActive ?? false
                } else {
                    return self.searchController?.isActive ?? false
                }
            }()

            guard isSearching else { return }
            self.updateSearchFilterContainerHeight(isSearching: isSearching)
        }
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
        filterContainer.preservesSuperviewLayoutMargins = true
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
        self.searchFilterViewController.view.preservesSuperviewLayoutMargins = true
        self.addChild(self.searchFilterViewController)
        self.searchFilterViewController.didMove(toParent: self)
    }

    private func updateSearchFilterContainerHeight(isSearching: Bool) {
        if isSearching {
            if #available(iOS 11, *) {
                self.filterContainerHeightConstraint?.constant = self.searchFilterViewController.preferredContentSize.height
            } else {
                self.filterContainerHeightConstraint?.constant = self.searchFilterViewController.preferredContentSize.height + 16
            }
        } else {
            self.filterContainerHeightConstraint?.constant = 0
        }
    }

    private func shareCourse(at indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath)
        let course = self.dataSource.object(at: indexPath)
        let activityViewController = UIActivityViewController.make(for: course, on: self)
        activityViewController.popoverPresentationController?.sourceView = cell
        self.present(activityViewController, animated: trueUnlessReduceMotionEnabled)
    }

    private func showCourseDates(course: Course) {
        let courseDatesViewController = R.storyboard.courseDates.instantiateInitialViewController().require()
        courseDatesViewController.course = course
        let navigationController = CustomWidthNavigationController(rootViewController: courseDatesViewController)
        self.present(navigationController, animated: trueUnlessReduceMotionEnabled)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = self.dataSource.object(at: indexPath)
        self.appNavigator?.show(course: course)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11, *) {
            // Required for showing the search bar on the initial load
            self.navigationController?.navigationBar.sizeToFit()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 11.0, *) {} else {
            self.collectionViewLayout.invalidateLayout()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _  in
            self.navigationController?.navigationBar.sizeToFit()
            self.collectionViewLayout.invalidateLayout()
        }
    }

    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemAt indexPath: IndexPath,
                                 point: CGPoint) -> UIContextMenuConfiguration? {
        let course = self.dataSource.object(at: indexPath)

        let previewProvider: UIContextMenuContentPreviewProvider = {
            return R.storyboard.coursePreview().instantiateInitialViewController { coder in
                return CoursePreviewViewController(coder: coder, course: course, listConfiguration: self.configuration)
            }
        }

        let actionProvider: UIContextMenuActionProvider = { _ in
            let userActions = [
                course.showCourseDatesAction { self.showCourseDates(course: course) },
                course.shareAction { self.shareCourse(at: indexPath) },
            ].compactMap { $0 }

            return UIMenu(title: "", children: userActions.asActions())
        }

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: previewProvider, actionProvider: actionProvider)
    }

    @available(iOS 13.0, *)
    override func collectionView(_ collectionView: UICollectionView,
                                 willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                                 animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            let course = self.dataSource.object(at: indexPath)
            self.appNavigator?.show(course: course)
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
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
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

    var heightForSectionHeader: CGFloat {
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

}

extension CourseListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)

        let boundingWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
        let minimalCardWidth = CourseCell.minimalWidth(for: self.traitCollection)
        let numberOfColumns = max(1, floor(boundingWidth / minimalCardWidth))
        let columnWidth = boundingWidth / numberOfColumns

        if self.dataSource.isSearching && !self.dataSource.hasSearchResults {
            return CGSize(width: columnWidth, height: 0)
        }

        let course = self.dataSource.object(at: indexPath)
        let height = CourseCell.heightForCourseList(forWidth: columnWidth, for: course)

        return CGSize(width: columnWidth, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftPadding = collectionView.layoutMargins.left - CourseCell.cardInset
        let rightPadding = collectionView.layoutMargins.right - CourseCell.cardInset

        return UIEdgeInsets(top: 0, left: leftPadding, bottom: collectionView.layoutMargins.bottom, right: rightPadding)
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
            // on iOS 10 the search bar's background will not overlap with the status bar, so we need the cover the status bar manually
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

        UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.collectionView.layoutIfNeeded()
        }
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.updateSearchFilterContainerHeight(isSearching: false)
        self.collectionViewLayout.invalidateLayout()

        UIView.animate(withDuration: defaultAnimationDuration, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.collectionView.layoutIfNeeded()
        }
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
                NSPredicate(format: "title CONTAINS[cd] %@", searchTextPart),
                NSPredicate(format: "teachers CONTAINS[cd] %@", searchTextPart),
                NSPredicate(format: "abstract CONTAINS[cd] %@", searchTextPart),
                NSPredicate(format: "slug CONTAINS[cd] %@", searchTextPart),
                NSPredicate(format: "categories CONTAINS[cd] %@", searchTextPart),
                NSPredicate(format: "topics CONTAINS[cd] %@", searchTextPart),
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
                        viewForAdditionalSupplementaryElementOfKind kind: String,
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

@available(iOS 11.0, *)
extension CourseListViewController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return [] }
        let selectedCourse = self.dataSource.object(at: indexPath)
        let courseCell = collectionView.cellForItem(at: indexPath) as? CourseCell
        return [selectedCourse.dragItem(with: courseCell?.previewView)]
    }

}
