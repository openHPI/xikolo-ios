//
//  CourseListViewController.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 08/07/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CoreData

class CourseListViewController : AbstractCourseListViewController {

    enum CourseDisplayMode {
        case enrolledOnly
        case all
        case explore
        case bothSectioned
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.collectionView?.emptyDataSetSource = nil
        self.collectionView?.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        let headerNib = UINib(nibName: "CourseHeaderView", bundle: nil)
        self.collectionView?.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CourseHeaderView")

        if let courseListLayout = self.collectionView?.collectionViewLayout as? CourseListLayout {
            courseListLayout.delegate = self
        }

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .automatic
        }

        courseDisplayMode = .all

        super.viewDidLoad()

        // setup pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.collectionView?.refreshControl = refreshControl

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CourseListViewController.updateAfterLoginStateChange),
                                               name: NotificationKeys.loginStateChangedKey,
                                               object: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView?.collectionViewLayout.invalidateLayout()
        coordinator.animate(alongsideTransition: { context in
            // Force redraw
            self.collectionView?.performBatchUpdates(nil, completion: nil)
        })
    }

    @objc func updateAfterLoginStateChange() {
        self.collectionView?.reloadEmptyDataSet()
    }

    @objc func refresh() {
        let deadline = UIRefreshControl.minimumSpinningTime.fromNow
        let stopRefreshControl = {
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.collectionView?.refreshControl?.endRefreshing()
            }
        }

        if UserProfileHelper.isLoggedIn() {
            CourseHelper.syncAllCourses().map { _ in
                return EnrollmentHelper.syncEnrollments()
            }.onComplete { _ in
                stopRefreshControl()
            }
        } else {
            CourseHelper.syncAllCourses().onComplete { _ in
                stopRefreshControl()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: "ShowCourseContent", sender: cell)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseContent"?:
                let vc = segue.destination as! CourseDecisionViewController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPath(for: cell)
                let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath!)!
                vc.course = controller.object(at: dataIndexPath)
            default:
                break
        }
    }

}

extension CourseListViewController: CourseListLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withBoundingWidth boundingWidth: CGFloat) -> CGFloat {
        let (controller, dataIndexPath) = self.resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath)!
        let course = controller.object(at: dataIndexPath)

        let imageHeight = boundingWidth / 2

        let boundingSize = CGSize(width: boundingWidth, height: CGFloat.infinity)
        let titleText = course.title ?? ""
        let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
        let titleSize = NSString(string: titleText).boundingRect(with: boundingSize,
                                                                          options: .usesLineFragmentOrigin,
                                                                          attributes: titleAttributes,
                                                                          context: nil)

        let teachersText = course.teachers ?? ""
        let teachersAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        let teachersSize = NSString(string: teachersText).boundingRect(with: boundingSize,
                                                                                options: .usesLineFragmentOrigin,
                                                                                attributes: teachersAttributes,
                                                                                context: nil)

        var height = imageHeight
        if !titleText.isEmpty || !teachersText.isEmpty {
            height += 6
        }
        if !titleText.isEmpty {
            height += titleSize.height
        }
        if !titleText.isEmpty && !teachersText.isEmpty {
            height += 4
        }
        if !teachersText.isEmpty {
            height += teachersSize.height
        }

        return height
    }
}
