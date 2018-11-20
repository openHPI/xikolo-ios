//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedDocumentsListViewController: UITableViewController {

    var courseID: String!

    private var dataSource: CoreDataTableViewDataSource<DownloadedDocumentsListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        guard let course = fetchCourse(withID: courseID) else { return }
        let request = DocumentLocalizationHelper.FetchRequest.downloadedDocumentLocalizations(forCourse: course)

        let reuseIdentifier = R.reuseIdentifier.downloadItemCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

    }

    func configure(for courseDownload: DownloadListViewController.CourseDownload) {
        self.courseID = courseDownload.id
        self.navigationItem.title = courseDownload.title
    }

    func fetchCourse(withID id: String) -> Course? {
        let request = CourseHelper.FetchRequest.course(withSlugOrId: id)
        return CoreDataHelper.viewContext.fetchSingle(request).value
    }

}

extension DownloadedDocumentsListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: DocumentLocalization) {
        cell.textLabel?.text = [object.document.title, object.languageCode].compactMap { $0 }.joined(separator: " - ")
        cell.detailTextLabel?.text = DocumentsPersistenceManager.shared.formattedFileSize(for: object)
    }

    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }

    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentLocalization = self.dataSource.object(at: indexPath)
            DocumentsPersistenceManager.shared.deleteDownload(for: documentLocalization)
        }
    }

}
