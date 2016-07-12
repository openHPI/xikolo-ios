//
//  LearningsViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 06.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import AVKit
import CoreData
import UIKit

class LearningsViewController : UIViewController {

    @IBOutlet weak var courseTitleView: UILabel!
    @IBOutlet weak var sectionTableView: UITableView!
    @IBOutlet weak var itemCollectionView: UICollectionView!

    @IBOutlet weak var errorMessageView: UILabel!

    var courseTabBarController: CourseTabBarController!
    var course: Course!

    var sectionResultsController: NSFetchedResultsController!
    var sectionResultsControllerDelegateImplementation: TableViewResultsControllerDelegateImplementation!
    var itemResultsController: NSFetchedResultsController?
    var itemResultsControllerDelegateImplementation: CollectionViewResultsControllerDelegateImplementation!

    override func viewDidLoad() {
        courseTabBarController = self.tabBarController as! CourseTabBarController
        course = courseTabBarController.course

        courseTitleView.text = course.name

        sectionResultsControllerDelegateImplementation = TableViewResultsControllerDelegateImplementation(sectionTableView)
        sectionResultsControllerDelegateImplementation.delegate = self

        let request = CourseSectionHelper.getSectionRequest(course)
        sectionResultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        sectionResultsController.delegate = sectionResultsControllerDelegateImplementation

        itemResultsControllerDelegateImplementation = CollectionViewResultsControllerDelegateImplementation(itemCollectionView)
        itemResultsControllerDelegateImplementation.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        checkDisplay()
        super.viewWillAppear(animated)
    }

    func checkDisplay() {
        if !UserProfileHelper.isLoggedIn() {
            showError(NSLocalizedString("You are currently not logged in.\nYou can only see a course's content when you're logged in.", comment: "You are currently not logged in.\nYou can only see a course's content when you're logged in."))
        } else if !course.is_enrolled {
            showError(NSLocalizedString("You are currently not enrolled in this course.\nYou can only see a course's content when you're enrolled.", comment: "You are currently not enrolled in this course.\nYou can only see a course's content when you're enrolled."))
        } else {
            hideError()
            loadSections()
        }
    }

    func showError(message: String) {
        errorMessageView.text = message
        errorMessageView.hidden = false
        sectionTableView.hidden = true
        itemCollectionView.hidden = true
    }

    func hideError() {
        errorMessageView.hidden = true
        sectionTableView.hidden = false
        itemCollectionView.hidden = false
    }

    func loadSections() {
        if sectionResultsController.fetchedObjects != nil {
            // The results controller has already loaded its data.
            return
        }

        do {
            try sectionResultsController.performFetch()

            if sectionResultsController.fetchedObjects!.count > 0 && sectionTableView.numberOfRowsInSection(0) > 0 {
                sectionTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Middle)
                if let section = sectionResultsController.fetchedObjects![0] as? CourseSection {
                    loadItemsForSection(section)
                }
            }
        } catch {
            // TODO: Error handling.
        }

        CourseSectionHelper.syncCourseSections(course)
    }

    func loadItemsForSection(section: CourseSection) {
        let request = CourseItemHelper.getItemRequest(section)
        itemCollectionView.reloadData()
        itemResultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: nil)
        itemResultsController!.delegate = itemResultsControllerDelegateImplementation

        do {
            try itemResultsController!.performFetch()
        } catch {
            // TODO: Error handling
        }

        CourseItemHelper.syncCourseItems(section)
    }

}

extension LearningsViewController : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionResultsController.sections?.count ?? 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = sectionResultsController.sections
        let sectionInfo = sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseSectionCell", forIndexPath: indexPath)
        configureTableCell(cell, indexPath: indexPath)
        return cell
    }

}

extension LearningsViewController : TableViewResultsControllerDelegateImplementationDelegate {

    func configureTableCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let cell = cell as! CourseSectionCell

        let section = sectionResultsController.objectAtIndexPath(indexPath) as! CourseSection
        cell.configure(section)
    }

}

extension LearningsViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let section = sectionResultsController.objectAtIndexPath(indexPath) as! CourseSection
        loadItemsForSection(section)
        return indexPath
    }

}

extension LearningsViewController : UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = itemResultsController?.sections {
            return sections.count
        } else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sections = itemResultsController!.sections! as [NSFetchedResultsSectionInfo]
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseItemCell", forIndexPath: indexPath)
        configureCollectionCell(cell, indexPath: indexPath)
        return cell
    }

}

extension LearningsViewController : CollectionViewResultsControllerDelegateImplementationDelegate {

    func configureCollectionCell(cell: UICollectionViewCell, indexPath: NSIndexPath) {
        let cell = cell as! CourseItemCell

        let item = itemResultsController!.objectAtIndexPath(indexPath) as! CourseItem
        cell.configure(item)
    }

}

extension LearningsViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = itemResultsController!.objectAtIndexPath(indexPath) as! CourseItem
        showItem(item)
    }

    func showItem(item: CourseItem) {
        switch item.content {
            case is RichText:
                performSegueWithIdentifier("ShowCourseItemRichTextSegue", sender: item)
            case is Video:
                let video = item.content as! Video
                VideoHelper.syncVideo(video).flatMap { video in
                    video.loadPoster()
                }.onSuccess {
                    self.performSegueWithIdentifier("ShowCourseItemVideoSegue", sender: video)
                }
            default:
                // TODO: show error: unsupported type
                break
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "ShowCourseItemRichTextSegue"?:
                let vc = segue.destinationViewController as! ItemRichTextController
                vc.courseItem = sender as! CourseItem
            case "ShowCourseItemVideoSegue"?:
                let vc = segue.destinationViewController as! AVPlayerViewController
                let video = sender as! Video
                if let url = video.single_stream_hls_url {
                    let playerItem = AVPlayerItem(URL: NSURL(string: url)!)
                    playerItem.externalMetadata = video.metadata()
                    let avPlayer = AVPlayer(playerItem: playerItem)
                    avPlayer.play()
                    vc.player = avPlayer
                }
            default:
                break
        }
    }

}
