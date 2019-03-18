//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData
import UIKit

class CourseListViewController: UICollectionViewController {

    private var dataSource: CoreDataCollectionViewDataSource<CourseListViewController>!

    @available(iOS, obsoleted: 11.0)
    private var searchController: UISearchController?

    @available(iOS, obsoleted: 11.0)
    private var statusBarBackground: UIView?

    private var filterContainerHeightConstraint: NSLayoutConstraint?
    private var searchFilterViewController: CourseSearchFiltersViewController?

    var configuration: CourseListConfiguration = .allCourses

    override func viewDidLoad() {
        self.collectionView?.register(R.nib.courseCell)
        self.collectionView?.register(UINib(resource: R.nib.courseHeaderView),
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: R.nib.courseHeaderView.name)

        if let courseListLayout = self.collectionView?.collectionViewLayout as? CardListLayout {
            courseListLayout.delegate = self
        }

        super.viewDidLoad()

        self.navigationItem.title = self.configuration.title
        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = self.configuration.largeTitleDisplayMode
        }

        self.addRefreshControl()

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
            searchController.searchBar.backgroundColor = .white
            searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            self.collectionView?.addSubview(searchController.searchBar)
            self.searchController = searchController
        }
    }

    private func addFilterView() {
        let filterContainer = UIView()
        filterContainer.backgroundColor = .blue
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

        let searchFilterViewController = CourseSearchFiltersViewController()
        filterContainer.addSubview(searchFilterViewController.view)
        searchFilterViewController.view.frame = filterContainer.frame
        self.addChild(searchFilterViewController)
        searchFilterViewController.didMove(toParent: self)
        self.searchFilterViewController = searchFilterViewController
    }

    private func updateSearchFilterContainerHeight(isSearching: Bool) {
        if isSearching {
            self.filterContainerHeightConstraint?.constant = CourseSearchFilterCell.size(for: .language, with: []).height + 2
        } else {
            self.filterContainerHeightConstraint?.constant = 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = self.dataSource.object(at: indexPath)
        AppNavigator.show(course: course)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
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
        guard self.configuration == .allCourses || self.dataSource.isSearching else {
            return 0 // Don't show header for these configurations
        }

        return ceil(CourseHeaderView.height)
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

        guard let searchText = searchController.searchBar.text, !searchText.isEmpty, searchController.isActive else {
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
            statusBarBackground.backgroundColor = .white
            self.view.addSubview(statusBarBackground)
            statusBarBackground.autoresizingMask = [.flexibleWidth]
            self.statusBarBackground = statusBarBackground
        }

        self.updateSearchFilterContainerHeight(isSearching: true)
        self.collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.collectionView.layoutIfNeeded()
        })
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.updateSearchFilterContainerHeight(isSearching: false)
        self.collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.collectionView.layoutIfNeeded()
        })

        #warning("Clear serach filters?")
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        self.addRefreshControl()

        if #available(iOS 11.0, *) {
            // nothing to do here
        } else {
            self.statusBarBackground?.removeFromSuperview()
        }
    }

}

extension CourseListViewController: CoreDataCollectionViewDataSourceDelegate {

    func configure(_ cell: CourseCell, for object: Course) {
        let filtered = self.configuration != .allCourses
        cell.configure(object, for: .courseList(filtered: filtered))
    }

    func configureHeaderView(_ headerView: CourseHeaderView, sectionInfo: NSFetchedResultsSectionInfo) {
        headerView.configure(sectionInfo)
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

        if let activeSearchFilters = self.searchFilterViewController?.activeFilters {
            let subpredicates = activeSearchFilters.map { (filter, selectedOptions) in filter.predicate(forSelectedOptions: selectedOptions) }
            let searchFilterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [searchTextPredicate, searchFilterPredicate])
        } else {
            return searchTextPredicate
        }

    }

    func configureSearchHeaderView(_ searchHeaderView: CourseHeaderView, numberOfSearchResults: Int) {
        let format = NSLocalizedString("%d courses found", tableName: "Common", comment: "<number> of courses found #bc-ignore!")
        searchHeaderView.configure(withText: String.localizedStringWithFormat(format, numberOfSearchResults))
    }

}

extension CourseListViewController: RefreshableViewController {

    func refreshingAction() -> Future<Void, XikoloError> {
        return CourseHelper.syncAllCourses().asVoid()
    }

}
