//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData

protocol DownloadedContentTypeListConfiguraton {

    associatedtype ManagerConfiguration: PersistenceManagerConfiguration

    static var persistenceManager: PersistenceManager<ManagerConfiguration> { get }
    static var cellTitleKeyPath: KeyPath<ManagerConfiguration.Resource, String?> { get }
    static var sectionTitleKeyPath: KeyPath<ManagerConfiguration.Resource, String?> { get }
    static var navigationTitle: String { get }

    static func resultsController(for course: Course) -> NSFetchedResultsController<ManagerConfiguration.Resource>
    static func show(_ object: ManagerConfiguration.Resource, with appNavigator: AppNavigator?)

}

enum DownloadedStreamsListConfiguration: DownloadedContentTypeListConfiguraton {

    typealias ManagerConfiguration = StreamPersistenceManagerConfiguration

    static let persistenceManager: PersistenceManager<ManagerConfiguration> = StreamPersistenceManager.shared
    static let cellTitleKeyPath = \Video.item?.title
    static let sectionTitleKeyPath = \Video.item?.section?.title
    static let navigationTitle = DownloadedContentHelper.ContentType.video.title

    static func resultsController(for course: Course) -> NSFetchedResultsController<Video> {
        let request = VideoHelper.FetchRequest.videosWithDownloadedStream(in: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
    }

    static func show(_ object: Video, with appNavigator: AppNavigator?) {
        guard let item = object.item else { return }
        appNavigator?.show(item: item)
    }

}

enum DownloadedSlidesListConfiguration: DownloadedContentTypeListConfiguraton {

    typealias ManagerConfiguration = SlidesPersistenceManagerConfiguration

    static let persistenceManager: PersistenceManager<ManagerConfiguration> = SlidesPersistenceManager.shared
    static let cellTitleKeyPath = \Video.item?.title
    static let sectionTitleKeyPath = \Video.item?.section?.title
    static let navigationTitle = DownloadedContentHelper.ContentType.slides.title

    static func resultsController(for course: Course) -> NSFetchedResultsController<Video> {
        let request = VideoHelper.FetchRequest.videosWithDownloadedSlides(in: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
    }

    static func show(_ object: Video, with appNavigator: AppNavigator?) {
        guard let item = object.item else { return }
        appNavigator?.show(item: item)
    }

}

enum DownloadedDocumentsListConfiguration: DownloadedContentTypeListConfiguraton {

    typealias ManagerConfiguration = DocumentPersistenceManagerConfiguration

    static let persistenceManager: PersistenceManager<ManagerConfiguration> = DocumentsPersistenceManager.shared
    static let cellTitleKeyPath = \DocumentLocalization.title as KeyPath<DocumentLocalization, String?>
    static let sectionTitleKeyPath = \DocumentLocalization.document.title as KeyPath<DocumentLocalization, String?>
    static let navigationTitle = DownloadedContentHelper.ContentType.document.title

    static func resultsController(for course: Course) -> NSFetchedResultsController<DocumentLocalization> {
        let request = DocumentLocalizationHelper.FetchRequest.downloadedDocumentLocalizations(forCourse: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title")
    }

    static func show(_ object: DocumentLocalization, with appNavigator: AppNavigator?) {
        appNavigator?.show(documentLocalization: object)
    }

}
