//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedVideosListViewController: UITableViewController {

    var courseID: String!

    private var dataSource: CoreDataTableViewDataSource<DownloadedVideosListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        let request = VideoHelper.FetchRequest.hasDownloadedVideo(inCourse: courseID)
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.title")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: "downloadItemCell",
                                                      delegate: self)
    }

    func configure(for courseDownload: CourseDownload) {
        self.courseID = courseDownload.id
        self.navigationItem.title = courseDownload.title
    }

}

extension DownloadedVideosListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: Video) {
        cell.textLabel?.text = object.item?.title
        cell.detailTextLabel?.text = StreamPersistenceManager.shared.formattedFileSize(for: object)
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }

    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = self.dataSource.object(at: indexPath)
            StreamPersistenceManager.shared.deleteDownload(for: video)
        }
    }

}
