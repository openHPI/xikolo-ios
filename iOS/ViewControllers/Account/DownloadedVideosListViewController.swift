//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedVideosListViewController: UITableViewController {

    var courseID: String!

    var resultsController: NSFetchedResultsController<Video>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let request: NSFetchRequest<Video> = VideoHelper.FetchRequest.hasDownloadedVideo(inCourse: courseID)
        resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.title")
        do {
            try resultsController.performFetch()
        } catch {
            log.error()
        }

    }

    func configure(for courseDownload: CourseDownload) {
        self.courseID = courseDownload.id
        self.navigationItem.title = courseDownload.title
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadItemCell", for: indexPath)
        let video = resultsController.object(at: indexPath)
        cell.textLabel?.text = video.item?.title ?? video.summary ?? ""
        cell.detailTextLabel?.text = StreamPersistenceManager.shared.formattedFileSize(for: video)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = resultsController.object(at: indexPath)
            StreamPersistenceManager.shared.deleteDownload(for: video)
        }
    }

}
