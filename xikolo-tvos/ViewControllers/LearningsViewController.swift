//
//  LearningsViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import SDWebImage

class LearningsViewController : UIViewController {

    @IBOutlet weak var courseTitleView: UILabel!
    @IBOutlet weak var sectionTableView: UITableView!
    @IBOutlet weak var itemCollectionView: UICollectionView!

    @IBOutlet weak var errorMessageView: UILabel!

    var courseTabBarController: CourseTabBarController!
    var course: Course!

    var sectionResultsController: NSFetchedResultsController<CourseSection>!
    var sectionResultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation<CourseSection>!
    var itemResultsController: NSFetchedResultsController<CourseItem>?
    var itemResultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation<CourseItem>!

    var backgroundImageHelper: ViewControllerBlurredBackgroundHelper!

    override func viewDidLoad() {
        courseTabBarController = self.tabBarController as! CourseTabBarController
        course = courseTabBarController.course

        courseTitleView.text = course.title

        backgroundImageHelper = ViewControllerBlurredBackgroundHelper(rootView: view)
        backgroundImageHelper.imageView.sd_setImage(with: course.image_url)

        let request = CourseSection.FetchRequest.courseSections(forCourse: self.course)
        sectionResultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        sectionResultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(sectionTableView, resultsController: [sectionResultsController], cellReuseIdentifier: "CourseSectionCell")
        let configuration = TableViewResultsControllerConfigurationWrapper(LearningsViewControllerSectionConfiguration())
        sectionResultsControllerDelegateImplementation.configuration = configuration
        sectionResultsController.delegate = sectionResultsControllerDelegateImplementation
        sectionTableView.dataSource = sectionResultsControllerDelegateImplementation
    }

    override func viewWillAppear(_ animated: Bool) {
        checkDisplay()
        super.viewWillAppear(animated)
    }

    func checkDisplay() {
        if !UserProfileHelper.isLoggedIn() {
            showError(NSLocalizedString("You are currently not logged in.\nYou can only see a course's content when you're logged in.", comment: "You are currently not logged in.\nYou can only see a course's content when you're logged in."))
        } else if course.enrollment == nil {
            showError(NSLocalizedString("You are currently not enrolled in this course.\nYou can only see a course's content when you're enrolled.", comment: "You are currently not enrolled in this course.\nYou can only see a course's content when you're enrolled."))
        } else {
            hideError()
            loadSections()
        }
    }

    func showError(_ message: String) {
        errorMessageView.text = message
        errorMessageView.isHidden = false
        sectionTableView.isHidden = true
        itemCollectionView.isHidden = true
    }

    func hideError() {
        errorMessageView.isHidden = true
        sectionTableView.isHidden = false
        itemCollectionView.isHidden = false
    }

    func loadSections() {
        if sectionResultsController.fetchedObjects != nil {
            // The results controller has already loaded its data.
            return
        }

        do {
            try sectionResultsController.performFetch()

            if sectionTableView.numberOfSections > 0 && sectionTableView.numberOfRows(inSection: 0) > 0 {
                sectionTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .middle)
                if let section = sectionResultsController.fetchedObjects![0] as? CourseSection {
                    loadItemsForSection(section)
                }
            }
        } catch {
            // TODO: Error handling.
        }

        CourseSectionHelper.syncCourseSections(forCourse: course)
    }

    func loadItemsForSection(_ section: CourseSection) {
        let request = CourseItem.FetchRequest.courseItems(forSection: section)
        itemCollectionView.reloadData()
        itemResultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)

        itemResultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(itemCollectionView, resultsControllers: [itemResultsController!], cellReuseIdentifier: "CourseItemCell")
        let configuration = CollectionViewResultsControllerConfigurationWrapper(LearningsViewControllerItemConfiguration())
        itemResultsControllerDelegateImplementation.configuration = configuration
        itemCollectionView.dataSource = itemResultsControllerDelegateImplementation
        itemResultsController!.delegate = itemResultsControllerDelegateImplementation
        itemResultsControllerDelegateImplementation.resultsControllers = [itemResultsController!]

        do {
            try itemResultsController!.performFetch()
        } catch {
            // TODO: Error handling
        }

        CourseItemHelper.syncCourseItems(forSection: section)
    }

}

extension LearningsViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = sectionResultsController.object(at: indexPath) as! CourseSection
        loadItemsForSection(section)
        return indexPath
    }

}

struct LearningsViewControllerSectionConfiguration : TableViewResultsControllerConfiguration {

    func configureTableCell(_ cell: UITableViewCell, for controller: NSFetchedResultsController<CourseSection>, indexPath: IndexPath) {
        let cell = cell as! CourseSectionCell
        let section = controller.object(at: indexPath)
        cell.configure(section)
    }

}

struct LearningsViewControllerItemConfiguration : CollectionViewResultsControllerConfiguration {

    func configureCollectionCell(_ cell: UICollectionViewCell, for controller: NSFetchedResultsController<CourseItem>, indexPath: IndexPath) {
        let cell = cell as! CourseItemCell
        let item = controller.object(at: indexPath)
        cell.configure(item)
    }

}

extension LearningsViewController : UICollectionViewDelegate, ItemViewControllerDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = itemResultsController!.object(at: indexPath) as! CourseItem
        showItem(item)
    }

    func showItem(_ item: CourseItem) {
        TrackingHelper.sendEvent(.visitedItem, resource: item)

        switch item.content {
            case is Quiz:
                let quiz = item.content as! Quiz
                performSegue(withIdentifier: "ShowCourseItemQuizSegue", sender: quiz)
            case is RichText:
                performSegue(withIdentifier: "ShowCourseItemRichTextSegue", sender: item)
            case is Video:
                let video = item.content as! Video
                performSegue(withIdentifier: "ShowCourseItemVideoSegue", sender: video)
            default:
                let title = NSLocalizedString("Unsupported item", comment: "Unsupported item")
                let message = NSLocalizedString("The type of this content item is unsupported on tvOS. Please use a different device to view it.", comment: "The type of this content item is unsupported on tvOS. Please use a different device to view it.")
                let ok = NSLocalizedString("OK", comment: "OK")

                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: ok, style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowCourseItemQuizSegue"?:
                let vc = segue.destination as! ItemQuizIntroductionController
                vc.quiz = sender as! Quiz
            case "ShowCourseItemRichTextSegue"?:
                let vc = segue.destination as! ItemRichTextController
                vc.delegate = self
                vc.courseItem = sender as! CourseItem
            case "ShowCourseItemVideoSegue"?:
                let vc = segue.destination as! ItemVideoLoadingController
                vc.video = sender as! Video
            default:
                break
        }
    }

}

protocol ItemViewControllerDelegate {

    func showItem(_ item: CourseItem)

}
