//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData

enum DownloadedContentHelper {

    struct DownloadItem {
        var courseID: String
        var courseTitle: String?
        var contentType: ContentType
        var fileSize: UInt64?
    }

    enum ContentType: CaseIterable {
        case video
        case slides
        case document

        var title: String {
            switch self {
            case .video:
                return NSLocalizedString("settings.downloads.item.video", comment: "download type video")
            case .slides:
                return NSLocalizedString("settings.downloads.item.slides", comment: "download type slides")
            case .document:
                return NSLocalizedString("settings.downloads.item.document", comment: "download type documents")
            }
        }

        var persistenceManager: ContentPersistanceManager {
            switch self {
            case .video:
                return StreamPersistenceManager.shared
            case .slides:
                return SlidesPersistenceManager.shared
            case .document:
                return DocumentsPersistenceManager.shared
            }
        }
    }

    static func downloadedItemForAllCourses() -> Future<[[DownloadItem]], XikoloError> {
        var futures = [
            self.streamCourseIDs(),
            self.slidesCourseIDs(),
        ]

        if Brand.default.features.enableDocuments {
            futures.append(self.documentsCourseIDs())
        }

        return futures.sequence()
    }

    private static func streamCourseIDs() -> Future<[DownloadItem], XikoloError> {
        return self.courseIDs(fetchRequest: VideoHelper.FetchRequest.videosWithDownloadedStream(),
                              contentType: .video,
                              keyPath: \Video.item?.section?.course,
                              persistenceManager: StreamPersistenceManager.shared)
    }

    private static func slidesCourseIDs() -> Future<[DownloadItem], XikoloError> {
        return self.courseIDs(fetchRequest: VideoHelper.FetchRequest.videosWithDownloadedSlides(),
                              contentType: .slides,
                              keyPath: \Video.item?.section?.course,
                              persistenceManager: SlidesPersistenceManager.shared)
    }

    private static func documentsCourseIDs() -> Future<[DownloadItem], XikoloError> {
        return self.courseIDs(fetchRequest: DocumentLocalizationHelper.FetchRequest.hasDownloadedLocalization(),
                              contentType: .document,
                              keyPath: \DocumentLocalization.document.courses,
                              persistenceManager: DocumentsPersistenceManager.shared)
    }

    private static func courseIDs<Resource, ManagerConfiguration>(
        fetchRequest: NSFetchRequest<Resource>,
        contentType: ContentType,
        keyPath: KeyPath<Resource, Course?>,
        persistenceManager: PersistenceManager<ManagerConfiguration>
    ) -> Future<[DownloadItem], XikoloError> where ManagerConfiguration: PersistenceManagerConfiguration, ManagerConfiguration.Resource == Resource {
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedItems = try privateManagedObjectContext.fetch(fetchRequest)
                for video in downloadedItems {
                    if let course = video[keyPath: keyPath] {
                        let fileSize = persistenceManager.fileSize(for: video)
                        items.append(DownloadItem(courseID: course.id, courseTitle: course.title, contentType: contentType, fileSize: fileSize))
                    }
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    private static func courseIDs<Resource, ManagerConfiguration>(
        fetchRequest: NSFetchRequest<Resource>,
        contentType: ContentType,
        keyPath: KeyPath<Resource, Set<Course>>,
        persistenceManager: PersistenceManager<ManagerConfiguration>
    ) -> Future<[DownloadItem], XikoloError> where ManagerConfiguration: PersistenceManagerConfiguration, ManagerConfiguration.Resource == Resource {
        var items: [DownloadItem] = []
        let promise = Promise<[DownloadItem], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedItems = try privateManagedObjectContext.fetch(fetchRequest)
                for item in downloadedItems {
                    let downloadItems = item[keyPath: keyPath].map { course -> DownloadItem in
                        let fileSize = persistenceManager.fileSize(for: item)
                        return DownloadItem(courseID: course.id, courseTitle: course.title, contentType: contentType, fileSize: fileSize)
                    }

                    items.append(contentsOf: downloadItems)
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

}
