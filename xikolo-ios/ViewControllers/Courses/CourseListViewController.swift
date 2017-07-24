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

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var numberOfItemsPerRow = 1

    enum CourseDisplayMode {
        case enrolledOnly
        case all
        case explore
        case bothSectioned
    }

    enum Views : Int {
        case myCourses = 0
        case exploreCourses = 1
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.collectionView?.emptyDataSetSource = nil
        self.collectionView?.emptyDataSetDelegate = nil
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        changeDisplayModeTo(sender.selectedSegmentIndex)
    }

    override func viewWillAppear(_ animated: Bool) {
        checkLoginState()
        updateView()
    }

    override func viewDidLoad() {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }
        super.viewDidLoad()
        presentWelcomeScreenIfNecessary()
    }

    func checkLoginState() {
        if !UserProfileHelper.isLoggedIn() {
            segmentedControl.selectedSegmentIndex = Views.exploreCourses.rawValue
            courseDisplayMode = .all
        }
    }

    func changeDisplayModeTo(_ selectedIndex: Int) {
        switch selectedIndex {
        case Views.myCourses.rawValue:
            if UserProfileHelper.isLoggedIn() {
                courseDisplayMode = .enrolledOnly
            } else {
                performSegue(withIdentifier: "ShowLogin", sender: self)
            }
        case Views.exploreCourses.rawValue:
            courseDisplayMode = UserProfileHelper.isLoggedIn() ? .explore : .all
        default:
            break
        }
        updateView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.horizontalSizeClass {
        case .compact, .unspecified:
            numberOfItemsPerRow = 1
        case .regular:
            numberOfItemsPerRow = 2
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            // Force redraw
            self.collectionView!.performBatchUpdates(nil, completion: nil)
        }, completion: nil)
    }

    func presentWelcomeScreenIfNecessary() {
        #if OPENWHO
        if UserProfileHelper.get(UserProfileHelper.Keys.welcome) == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            guard let start = formatter.date(from: "20170521"), let end = formatter.date(from: "20170530") else { return }
            let healthConference = DateInterval.init(start: start, end: end)
            let now = Date.init(timeIntervalSinceNow: 0)
            if (healthConference.contains(now)) {
                performSegue(withIdentifier: "ShowWelcome", sender: nil)
                UserProfileHelper.save(UserProfileHelper.Keys.welcome, withValue: "showed")
            }
        }
        #endif
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseContent"?:
                let vc = segue.destination as! CourseDecisionViewController
                let cell = sender as! CourseCell
                let indexPath = collectionView!.indexPath(for: cell)
                let (controller, dataIndexPath) = resultsControllerDelegateImplementation.controllerAndImplementationIndexPath(forVisual: indexPath!)!
                let course = controller.object(at: dataIndexPath)
                vc.course = try! CourseHelper.getByID(course.id) // TODO:
            default:
                break
        }
    }

    @IBAction func unwindLogin(_ segue: UIStoryboardSegue) {
        if !UserProfileHelper.isLoggedIn() {
            segmentedControl.selectedSegmentIndex = 1
            changeDisplayModeTo(Views.exploreCourses.rawValue)
        } else {
            changeDisplayModeTo(Views.myCourses.rawValue)
        }
    }

}

extension CourseListViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let blankSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            let width = (collectionView.bounds.width - blankSpace) / CGFloat(numberOfItemsPerRow)
            return CGSize(width: width, height: width * 0.6)
    }

}
