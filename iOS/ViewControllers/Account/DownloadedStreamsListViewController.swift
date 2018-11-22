//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedStreamsListViewController: UITableViewController {

    var courseId: String!

    private var dataSource: CoreDataTableViewDataSource<DownloadedStreamsListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = DownloadedContentListViewController.DownloadType.video.title
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        let request = VideoHelper.FetchRequest.videosWithDownloadedStream(inCourse: self.courseId)
        let reuseIdentifier = R.reuseIdentifier.downloadItemCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)
    }

    func configure(forCourseWithId courseId: String) {
        self.courseId = courseId
    }

}

extension DownloadedStreamsListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: Video) {
        cell.textLabel?.text = object.item?.title
        cell.detailTextLabel?.text = StreamPersistenceManager.shared.formattedFileSize(for: object)
    }

    func titleForDefaultHeader(forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        guard let dataSource = self.dataSource else { return nil }
        return dataSource.object(at: indexPath).item?.section?.title
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
