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
        self.collectionView?.performBatchUpdates(nil)
    }

}

extension CourseListViewController: CardListLayoutDelegate {

    var showHeaders: Bool {
        return self.configuration == .allCourses || self.dataSource.isSearching
    }

    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        if self.dataSource.isSearching && !self.dataSource.hasSearchResults {
            return 0.0
        }

        let course = self.dataSource.object(at: indexPath)
        let cardWidth = boundingWidth - 2 * 14
        let imageHeight = cardWidth / 2

        let titleHeight = course.title?.height(forTextStyle: .headline, boundingWidth: cardWidth) ?? 0
        let teachersHeight = course.teachers?.height(forTextStyle: .subheadline, boundingWidth: cardWidth) ?? 0

        var height = imageHeight + 14

        if Brand.default.features.showCourseTeachers {
            if titleHeight > 0 || teachersHeight > 0 {
                height += 8
            }

            if titleHeight > 0 && teachersHeight > 0 {
                height += 4
            }

            height += titleHeight
            height += teachersHeight
        } else {
            height += 8
            height += titleHeight
        }

        return height + 5
    }

    func topInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            return 0
        } else {
            return self.searchController?.searchBar.bounds.height ?? 0
        }
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

        self.collectionView?.setContentOffset(scrollOffset, animated: true)

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
            ])
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)
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
