//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Common
import UIKit

class DownloadedSlidesListViewController: UITableViewController {

    var courseID: String!

    private var dataSource: CoreDataTableViewDataSource<DownloadedSlidesListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()
        let request: NSFetchRequest<Video> = VideoHelper.FetchRequest.hasDownloadedSlides(inCourse: courseID)

        let reuseIdentifier = "downloadItemCell"
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.title")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

    }

    func configure(for courseID: String) {
        self.courseID = courseID
    }

}

extension DownloadedSlidesListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: Video) {
        cell.textLabel?.text = object.item?.title ?? object.summary
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }

    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = self.dataSource.object(at: indexPath)
            SlidesPersistenceManager.shared.deleteDownload(for: video)
        }
    }

}
