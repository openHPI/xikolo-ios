//
//  Created for xikolo-ios under MIT license.
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

    func startDownload(for video: Video) {
        guard let url = video.slidesURL else { return }
        return self.startDownload(with: url, for: video)
    }

    private func trackingContext(for video: Video) -> [String: String?] {
        return [
            "section_id": video.item?.section?.id,
            "course_id": video.item?.section?.course?.id,
            "free_space": String(describing: SlidesPersistenceManager.systemFreeSize),
            "total_space": String(describing: SlidesPersistenceManager.systemSize),
        ]
    }

    override func didStartDownload(for resource: Video) {
        TrackingHelper.createEvent(.slidesDownloadStart,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource))
    }

    override func didCancelDownload(for resource: Video) {
        TrackingHelper.createEvent(.slidesDownloadCanceled,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource))
    }

    override func didFinishDownload(for resource: Video) {
        TrackingHelper.createEvent(.slidesDownloadFinished,
                                   resourceType: .video,
                                   resourceId: resource.id,
                                   on: nil,
                                   context: self.trackingContext(for: resource))
    }

}

extension SlidesPersistenceManager {


    func startDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return self.downloadState(for: video) == .notDownloaded
            }.forEach { video in
                self.startDownload(for: video)
            }
        }
    }

    func deleteDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.forEach { video in
                self.deleteDownload(for: video)
            }
        }
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
