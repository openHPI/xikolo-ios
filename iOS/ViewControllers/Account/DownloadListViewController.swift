//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

class DownloadListViewController: UITableViewController {

    var dataSource: CoreDataTableViewDataSource<DownloadListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup table view data
        let reuseIdentifier = R.reuseIdentifier.downloadedCourse.identifier
        let request = CourseHelper.FetchRequest.coursesWithDownloads
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "title") // must be the first sort descriptor
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)


        let videoRequest = VideoHelper.FetchRequest.hasDownloadedVideo()
        let slidesRequest = VideoHelper.FetchRequest.hasDownloadedSlides()
        var courseIDs: Set<String> = Set()
        //let documentsRequest =
        do {
            let downloadedVideos = try CoreDataHelper.persistentContainer.newBackgroundContext().fetch(videoRequest)
            let downloadedSlides = try CoreDataHelper.persistentContainer.newBackgroundContext().fetch(slidesRequest)
            for video in downloadedVideos {
                if let courseID = video.item?.section?.course?.id {
                    courseIDs.update(with: courseID)
                }

            }
            for slide in downloadedSlides {
                if let courseID = slide.item?.section?.course?.id {
                    courseIDs.update(with: courseID)
                }
            }
        } catch {

        }
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0

        if false { // TODO: check for runnning Downloads
            numberOfSections += 1
        }

        if Brand.default.features.enableDocuments {
            numberOfSections += 1
        }

        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

extension DownloadListViewController: CoreDataTableViewDataSourceDelegate {
    typealias Object = Course
    typealias Cell = DownloadedCourseCell

    func configure(_ cell: Cell, for object: Object) {
        cell.configure(for: object)
    }

}
