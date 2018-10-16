//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Common
import UIKit

class DownloadItemListViewController: UITableViewController {

    var downloadType: DownloadItem.DownloadType!
    var courseID: String!

    var sections: [Int:Int] = [:]

    var resultsController: NSFetchedResultsController<Video>!

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
        var request: NSFetchRequest<Video>
        switch self.downloadType {
        case .video?:
            request = VideoHelper.FetchRequest.hasDownloadedVideo(inCourse: courseID)
        case .slides?:
            request = VideoHelper.FetchRequest.hasDownloadedSlides(inCourse: courseID)
        default:
            request = Video.fetchRequest()
        }
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.title")
        do {
            try resultsController.performFetch()
            //self.tableView.reloadData()
        } catch {
            log.error()
        }

    }

    func configure(for courseID: String ,withDownloadType downloadType: DownloadItem.DownloadType) {
        self.downloadType = downloadType
        self.courseID = courseID
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
//        let videos = resultsController.fetchedObjects.require()
//        videos.forEach { (video) in
//            if let section = video.item?.section {
//                let count = (sections[Int(section.position)] ?? 0) + 1
//                sections.updateValue(count, forKey: Int(section.position))
//            }
//        }
        //return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadItemCell", for: indexPath)
        let video = resultsController.object(at: indexPath)
        cell.textLabel?.text = video.item?.title ?? video.summary ?? ""
        //cell.detailTextLabel?.text = self.downloadType == .video ? video.singleStream.
        // TODO: maybe set size
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
