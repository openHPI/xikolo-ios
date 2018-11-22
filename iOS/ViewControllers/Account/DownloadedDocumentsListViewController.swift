//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import UIKit

class DownloadedDocumentsListViewController: UITableViewController {

    var courseId: String!

    private var dataSource: CoreDataTableViewDataSource<DownloadedDocumentsListViewController>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = DownloadedContentListViewController.DownloadType.document.title
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        guard let course = self.fetchCourse(withID: self.courseId) else { return }
        let request = DocumentLocalizationHelper.FetchRequest.downloadedDocumentLocalizations(forCourse: course)

        let reuseIdentifier = R.reuseIdentifier.downloadItemCell.identifier
        let resultsController = CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title")
        self.dataSource = CoreDataTableViewDataSource(self.tableView,
                                                      fetchedResultsController: resultsController,
                                                      cellReuseIdentifier: reuseIdentifier,
                                                      delegate: self)

    }

    func configure(forCourseWithId courseId: String) {
        self.courseId = courseId
    }

    func fetchCourse(withID id: String) -> Course? {
        let request = CourseHelper.FetchRequest.course(withSlugOrId: id)
        return CoreDataHelper.viewContext.fetchSingle(request).value
    }

}

extension DownloadedDocumentsListViewController: CoreDataTableViewDataSourceDelegate {

    func configure(_ cell: UITableViewCell, for object: DocumentLocalization) {
        cell.textLabel?.text = object.languageCode
        cell.detailTextLabel?.text = DocumentsPersistenceManager.shared.formattedFileSize(for: object)
    }

    func titleForDefaultHeader(forSection section: Int) -> String? {
        let indexPath = IndexPath(row: 0, section: section)
        guard let dataSource = self.dataSource else { return nil }
        return dataSource.object(at: indexPath).document.title
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
