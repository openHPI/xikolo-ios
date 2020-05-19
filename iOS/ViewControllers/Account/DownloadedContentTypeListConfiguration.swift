//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData

protocol DownloadedContentTypeListConfiguration {

    associatedtype ManagerConfiguration: PersistenceManagerConfiguration

    static var persistenceManager: PersistenceManager<ManagerConfiguration> { get }
    static var cellTitleKeyPath: KeyPath<ManagerConfiguration.Resource, String?> { get }
    static var sectionTitleKeyPath: KeyPath<ManagerConfiguration.Resource, String?> { get }
    static var timeEffortKeyPath: KeyPath<ManagerConfiguration.Resource, Int16?>? { get }
    static var contentType: DownloadedContentHelper.ContentType { get }

    static func resultsController(for course: Course) -> NSFetchedResultsController<ManagerConfiguration.Resource>
    static func show(_ object: ManagerConfiguration.Resource, with appNavigator: AppNavigator?)

}

enum DownloadedStreamsListConfiguration: DownloadedContentTypeListConfiguration {

    typealias ManagerConfiguration = StreamPersistenceManager.Configuration

    static let persistenceManager: PersistenceManager<ManagerConfiguration> = StreamPersistenceManager.shared
    static let cellTitleKeyPath = \Video.item?.title
    static let sectionTitleKeyPath = \Video.item?.section?.title
    static let timeEffortKeyPath: KeyPath<Video, Int16?>? = \Video.item?.timeEffort
    static let contentType = DownloadedContentHelper.ContentType.video

    static func resultsController(for course: Course) -> NSFetchedResultsController<Video> {
        let request = VideoHelper.FetchRequest.videosWithDownloadedStream(in: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
    }

    static func show(_ object: Video, with appNavigator: AppNavigator?) {
        guard let item = object.item else { return }
        appNavigator?.show(item: item)
    }

}

enum DownloadedSlidesListConfiguration: DownloadedContentTypeListConfiguration {

    typealias ManagerConfiguration = SlidesPersistenceManager.Configuration

    static let persistenceManager: PersistenceManager<ManagerConfiguration> = SlidesPersistenceManager.shared
    static let cellTitleKeyPath = \Video.item?.title
    static let sectionTitleKeyPath = \Video.item?.section?.title
    static var timeEffortKeyPath: KeyPath<Video, Int16?>? = \Video.item?.timeEffort
    static let contentType = DownloadedContentHelper.ContentType.slides

    static func resultsController(for course: Course) -> NSFetchedResultsController<Video> {
        let request = VideoHelper.FetchRequest.videosWithDownloadedSlides(in: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "item.section.position")
    }

    static func show(_ object: Video, with appNavigator: AppNavigator?) {
        guard let item = object.item else { return }
        appNavigator?.show(item: item)
    }

}

enum DownloadedDocumentsListConfiguration: DownloadedContentTypeListConfiguration {

    typealias ManagerConfiguration = DocumentsPersistenceManager.Configuration

    static let persistenceManager: PersistenceManager<ManagerConfiguration> = DocumentsPersistenceManager.shared
    static let cellTitleKeyPath = \DocumentLocalization.title as KeyPath<DocumentLocalization, String?>
    static let sectionTitleKeyPath = \DocumentLocalization.document.title as KeyPath<DocumentLocalization, String?>
    static let timeEffortKeyPath: KeyPath<DocumentLocalization, Int16?>? = nil
    static let contentType = DownloadedContentHelper.ContentType.document

    static func resultsController(for course: Course) -> NSFetchedResultsController<DocumentLocalization> {
        let request = DocumentLocalizationHelper.FetchRequest.downloadedDocumentLocalizations(forCourse: course)
        return CoreDataHelper.createResultsController(request, sectionNameKeyPath: "document.title")
    }

    static func show(_ object: DocumentLocalization, with appNavigator: AppNavigator?) {
        appNavigator?.show(documentLocalization: object)
    }

}
