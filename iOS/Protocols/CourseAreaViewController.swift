//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

protocol CourseAreaViewController: AnyObject {

//    var scrollDelegate: CourseAreaScrollDelegate? { get set }
    var courseAreaScrollView: UIScrollView { get }

    var area: CourseArea { get }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate)

}

protocol CourseAreaScrollDelegate: AnyObject {

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollToTop(_ scrollView: UIScrollView)

}

protocol CourseAreaEnrollmentDelegate: AnyObject {

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool)

}

typealias CourseAreaViewControllerDelegate = CourseAreaScrollDelegate & CourseAreaEnrollmentDelegate

extension CourseAreaViewController where Self: UITableViewController {

    var courseAreaScrollView: UIScrollView {
        return self.tableView
    }

}

extension CourseAreaViewController where Self: UICollectionViewController {

    var courseAreaScrollView: UIScrollView {
        return self.collectionView
    }

}
