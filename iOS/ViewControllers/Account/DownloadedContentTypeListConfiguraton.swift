//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData

protocol DownloadedContentTypeListConfiguraton {

    associatedtype Manager: PersistenceManager

    static var persistenceManager: Manager { get }
    static var cellTitleKeyPath: KeyPath<Manager.Resource, String?> { get }
    static var sectionTitleKeyPath: KeyPath<Manager.Resource, String?> { get }
    static var navigationTitle: String { get }

    static func resultsController(for course: Course) -> NSFetchedResultsController<Manager.Resource>
    static func show(_ object: Manager.Resource)

}

enum DownloadedStreamsListConfiguration: DownloadedContentTypeListConfiguraton {

    static let persistenceManager = StreamPersistenceManager.shared
    static let cellTitleKeyPath = \Video.item?.title
    static let sectionTitleKeyPath = \Video.item?.section?.title
    static let navigationTitle = DownloadedContentListViewController.DownloadedContentType.video.title

    static func resultsController(for course: Course) -> NSFetchedResultsController<Video> {
        let request = VideoHelper.FetchRequest.videosWithDownloadedStream(in: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
    }

    static func show(_ object: Video) {
        guard let item = object.item else { return }
        AppNavigator.show(item: item)
    }

}

enum DownloadedSlidesListConfiguration: DownloadedContentTypeListConfiguraton {

    static let persistenceManager = SlidesPersistenceManager.shared
    static let cellTitleKeyPath = \Video.item?.title
    static let sectionTitleKeyPath = \Video.item?.section?.title
    static let navigationTitle = DownloadedContentListViewController.DownloadedContentType.slides.title

    static func resultsController(for course: Course) -> NSFetchedResultsController<Video> {
        let request = VideoHelper.FetchRequest.videosWithDownloadedSlides(in: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
    }

    static func show(_ object: Video) {
        guard let item = object.item else { return }
        AppNavigator.show(item: item)
    }

}

enum DownloadedDocumentsListConfiguration: DownloadedContentTypeListConfiguraton {

    static let persistenceManager = DocumentsPersistenceManager.shared
    static let cellTitleKeyPath = \DocumentLocalization.title as KeyPath<DocumentLocalization, String?>
    static let sectionTitleKeyPath = \DocumentLocalization.document.title as KeyPath<DocumentLocalization, String?>
    static let navigationTitle = DownloadedContentListViewController.DownloadedContentType.document.title

    static func resultsController(for course: Course) -> NSFetchedResultsController<DocumentLocalization> {
        let request = DocumentLocalizationHelper.FetchRequest.downloadedDocumentLocalizations(forCourse: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title")
    }

    static func show(_ object: DocumentLocalization) {
        AppNavigator.show(documentLocalization: object)
    }

}
