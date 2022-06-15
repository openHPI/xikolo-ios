//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Common
import CoreData

final class SlidesPersistenceManager: FilePersistenceManager<SlidesPersistenceManager.Configuration> {

    enum Configuration: PersistenceManagerConfiguration {

        // swiftlint:disable nesting
        typealias Resource = Video
        typealias Session = URLSession
        // swiftlint:enable nesting

        static let keyPath = \Video.localSlidesBookmark
        static let downloadType = "slides"
        static let titleForFailedDownloadAlert = NSLocalizedString("alert.download-error.slides.title",
                                                                   comment: "title of alert for slides download errors")

        static func newFetchRequest() -> NSFetchRequest<Video> {
            return Video.fetchRequest()
        }

    }

    static let shared = SlidesPersistenceManager()

    override func newDownloadSession() -> URLSession {
        return self.createURLSession(withIdentifier: "slides-download")
    }

    private func trackingContext(for video: Video, options: [Option]) -> [String: String?] {
        var context = [
            "section_id": video.item?.section?.id,
            "course_id": video.item?.section?.course?.id,
            "free_space": String(describing: SlidesPersistenceManager.systemFreeSize),
            "total_space": String(describing: SlidesPersistenceManager.systemSize),
        ]

        for case let .trackingContext(additionalContext) in options {
            context.merge(additionalContext) { $1 }
        }

        return context
    }

    override func didStartDownload(for resource: Video, options: [Option]) {
        TrackingHelper.createEvent(.slidesDownloadStart,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource, options: options))
    }

    override func didCancelDownload(for resource: Video, options: [Option]) {
        TrackingHelper.createEvent(.slidesDownloadCanceled,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource, options: options))
    }

    override func didFinishDownload(for resource: Video, options: [Option]) {
        TrackingHelper.createEvent(.slidesDownloadFinished,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource, options: options))
    }

}

extension SlidesPersistenceManager {

    @discardableResult
    func startDownload(for video: Video, options: [SlidesPersistenceManager.Option] = []) -> Future<Void, XikoloError> {
        guard let url = video.slidesURL else { return Future(error: .totallyUnknownError) }
        return self.startDownload(with: url, for: video, options: options)
    }

    @discardableResult
    func startDownloads(for section: CourseSection, options: [SlidesPersistenceManager.Option] = []) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        self.persistentContainerQueue.addOperation {
            let sectionDownloadFuture = section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return self.downloadState(for: video) == .notDownloaded
            }.map { video in
                self.startDownload(for: video, options: options)
            }.sequence().asVoid()

            promise.completeWith(sectionDownloadFuture)
        }

        return promise.future
    }

    @discardableResult
    func deleteDownloads(for section: CourseSection) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        self.persistentContainerQueue.addOperation {
            let sectionDeleteFuture = section.items.compactMap { item in
                return item.content as? Video
            }.map { video in
                self.deleteDownload(for: video)
            }.sequence().asVoid()

            return promise.completeWith(sectionDeleteFuture)
        }

        return promise.future
    }

    func cancelDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return [.pending, .downloading].contains(SlidesPersistenceManager.shared.downloadState(for: video))
            }.forEach { video in
                self.cancelDownload(for: video)
            }
        }
    }

}
