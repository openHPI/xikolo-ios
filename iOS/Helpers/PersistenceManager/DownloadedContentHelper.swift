//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData

enum DownloadedContentHelper {

    struct DownloadContent {
        var courseID: String
        var courseTitle: String?
        var contentType: ContentType
        var fileSize: UInt64?
        var timeEffort: Int16?
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

        func transformTimeEffort(_ originalTimeEffort: Int16) -> Int16 {
            switch self {
            case .slides:
                // For slides, the original time effort references the duration of the video,
                // Because of this, we calculate reading time for the slides based on the speaking time (video duration)
                // First the word count is estimated for the speaking time, then the reading time is estimated for the word count.
                let estimatedWordCount = 1060.47 * log(0.00689788 * Double(originalTimeEffort))
                let estimatedReadingTime = 61.3909 * pow(M_E, 0.00104176 * estimatedWordCount)
                return Int16(ceil(estimatedReadingTime))
            default:
                return originalTimeEffort
            }
        }
    }

    static func downloadedContentForAllCourses() -> Future<[DownloadContent], XikoloError> {
        var futures = [
            self.downloadedStreamContent(),
            self.downloadedSlidesContent(),
        ]

        if Brand.default.features.enableDocuments {
            futures.append(self.downloadedDocumentsContent())
        }

        return futures.sequence().map { list in list.flatMap { $0 } }
    }

    private static func downloadedStreamContent() -> Future<[DownloadContent], XikoloError> {
        return self.downloadedContent(fetchRequest: VideoHelper.FetchRequest.videosWithDownloadedStream(),
                                      contentType: .video,
                                      courseKeyPath: \Video.item?.section?.course,
                                      courseItemKeyPath: \Video.item,
                                      persistenceManager: StreamPersistenceManager.shared)
    }

    private static func downloadedSlidesContent() -> Future<[DownloadContent], XikoloError> {
        return self.downloadedContent(fetchRequest: VideoHelper.FetchRequest.videosWithDownloadedSlides(),
                                      contentType: .slides,
                                      courseKeyPath: \Video.item?.section?.course,
                                      courseItemKeyPath: \Video.item,
                                      persistenceManager: SlidesPersistenceManager.shared)
    }

    // todo: rename
    private static func downloadedDocumentsContent() -> Future<[DownloadContent], XikoloError> {
        return self.downloadedContent(fetchRequest: DocumentLocalizationHelper.FetchRequest.hasDownloadedLocalization(),
                                      contentType: .document,
                                      courseKeyPath: \DocumentLocalization.document.courses,
                                      persistenceManager: DocumentsPersistenceManager.shared)
    }

    private static func downloadedContent<Resource, Manager>(
        fetchRequest: NSFetchRequest<Resource>,
        contentType: ContentType,
        courseKeyPath: KeyPath<Resource, Course?>,
        courseItemKeyPath: KeyPath<Resource, CourseItem?>? = nil,
        persistenceManager: Manager
    ) -> Future<[DownloadContent], XikoloError> where Manager: PersistenceManager, Manager.Resource == Resource {
        var items: [DownloadContent] = []
        let promise = Promise<[DownloadContent], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedResources = try privateManagedObjectContext.fetch(fetchRequest)
                for resource in downloadedResources {
                    if let course = resource[keyPath: courseKeyPath] {
                        let fileSize = persistenceManager.fileSize(for: resource)
                        let courseItem = courseItemKeyPath.flatMap { resource[keyPath: $0] }
                        let originalTimeEffort = courseItem?.timeEffort
                        let timeEffort = originalTimeEffort.map { contentType.transformTimeEffort($0) }
                        let item = DownloadContent(courseID: course.id,
                                                courseTitle: course.title,
                                                contentType: contentType,
                                                fileSize: fileSize,
                                                timeEffort: timeEffort)
                        items.append(item)
                    }
                }

                return promise.success(items)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    private static func downloadedContent<Resource, Manager>(
        fetchRequest: NSFetchRequest<Resource>,
        contentType: ContentType,
        courseKeyPath: KeyPath<Resource, Set<Course>>,
        persistenceManager: Manager
    ) -> Future<[DownloadContent], XikoloError> where Manager: PersistenceManager, Manager.Resource == Resource {
        var items: [DownloadContent] = []
        let promise = Promise<[DownloadContent], XikoloError>()
        CoreDataHelper.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            do {
                let downloadedResources = try privateManagedObjectContext.fetch(fetchRequest)
                for resource in downloadedResources {
                    let downloadItems = resource[keyPath: courseKeyPath].map { course -> DownloadContent in
                        let fileSize = persistenceManager.fileSize(for: resource)
                        return DownloadContent(courseID: course.id,
                                            courseTitle: course.title,
                                            contentType: contentType,
                                            fileSize: fileSize)
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
