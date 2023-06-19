//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BackgroundTasks
import BrightFutures
import Common
import CoreData
import UserNotifications

@available(iOS 13, *)
enum AutomatedDownloadsManager {

    enum DownloadTrigger: String {
        case setup
        case notification
        case appLaunch = "app_launch"
        case backgroundTask = "background_task"

        var trackingContext: [String: String?] {
            return ["download_trigger": self.rawValue]
        }
    }

    static let taskIdentifier = "de.xikolo.ios.new-content.download.background"
    static let urlSessionIdentifier = "de.xikolo.ios.new-content.download.sync"

    static let networker = XikoloBackgroundNetworker(withIdentifier: Self.urlSessionIdentifier, saveBattery: true) {
        Self.backgroundCompletionHandler?()
    }

    static var backgroundCompletionHandler: (() -> Void)?

    // This excludes processing via the background API
    static var dispatchQueueForProcessings = DispatchQueue(label: "automated-downloads-trigger", qos: .background)
    static var runningProcessing: (startDate: Date, future: Future<Void, XikoloError>)?

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.performNextBackgroundProcessingTasks(task: task)
        }
    }

    // - schedule next background task (find next sections/course -> start change date for existing bg task or cancel | setup new bgtask)
    static func scheduleNextBackgroundProcessingTask(context: NSManagedObjectContext = CoreDataHelper.persistentContainer.newBackgroundContext()) {
        // Find next date for background processing
        guard let dateForNextBackgroundProcessing = self.dateForNextBackgroundProcessing(in: context) else {
            return
        }

        // Cancel current task request
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)

        // Setup new task request
        let automatedDownloadTaskRequest = BGProcessingTaskRequest(identifier: Self.taskIdentifier)
        automatedDownloadTaskRequest.earliestBeginDate = dateForNextBackgroundProcessing
        automatedDownloadTaskRequest.requiresNetworkConnectivity = true
        try? BGTaskScheduler.shared.submit(automatedDownloadTaskRequest)
    }

    static func dateForNextBackgroundProcessing(in context: NSManagedObjectContext) -> Date? {
        // Are there pending downloads? If yes, return the current date to run the background task as early as possible.
        if self.pendingDownloadsOrDeletionsExist(in: context) {
            return Date()
        }

        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)
        let nextDates: [Date]? = courses?.compactMap { course -> Date? in
            guard course.automatedDownloadSettings?.newContentAction == .notificationAndBackgroundDownload else { return nil }
            let courseDates = [course.startsAt, course.endsAt].compactMap { $0 }
            let sectionDates = course.sections.compactMap(\.startsAt)
            let dates = sectionDates + courseDates
            return dates.filter(\.inFuture).min()
        }

        return nextDates?.min()
    }

    static func performNextBackgroundProcessingTasks(task: BGTask) {
        let context = CoreDataHelper.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        task.expirationHandler = {
            self.scheduleNextBackgroundProcessingTask(context: context)

            StreamPersistenceManager.shared.persistentContainerQueue.cancelAllOperations()
            StreamPersistenceManager.shared.session.invalidateAndCancel()
            SlidesPersistenceManager.shared.persistentContainerQueue.cancelAllOperations()
            SlidesPersistenceManager.shared.session.invalidateAndCancel()

            task.setTaskCompleted(success: false)
        }

        let processingFuture = self.processPendingDownloadsAndDeletions(in: context, triggeredBy: .backgroundTask)

        processingFuture.onComplete { result in
            self.scheduleNextBackgroundProcessingTask(context: context)
            task.setTaskCompleted(success: result.value != nil)
        }
    }

    @discardableResult
    static func processPendingDownloadsAndDeletions(triggeredBy trigger: DownloadTrigger) -> Future<Void, XikoloError> {
        self.dispatchQueueForProcessings.sync {
            if let runningProcessing = self.runningProcessing, runningProcessing.startDate.addingTimeInterval(10 * 60).inFuture {
                return runningProcessing.future
            }

            let promise = Promise<Void, XikoloError>()
            let future = promise.future
            self.runningProcessing = (Date(), future)

            future.onComplete { _ in
                Self.runningProcessing = nil
            }

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let processingFuture = Self.processPendingDownloadsAndDeletions(in: context, triggeredBy: trigger)
                promise.completeWith(processingFuture)
            }

            return future
        }
    }

    @discardableResult
    private static func processPendingDownloadsAndDeletions(
        in context: NSManagedObjectContext,
        triggeredBy trigger: DownloadTrigger
    ) -> Future<Void, XikoloError> {
        let refreshFuture = self.refreshCourseItemsOfRelevantCourses(in: context)
        let processingFuture = refreshFuture.flatMap { _ -> Future<Void, XikoloError> in
            let downloadFuture = self.downloadNewContent(in: context, triggeredBy: trigger)
            let deleteFuture = self.deleteOldContent(in: context)
            return [downloadFuture, deleteFuture].sequence().asVoid()
        }

        return processingFuture
    }

    private static func refreshCourseItemsOfRelevantCourses(in context: NSManagedObjectContext) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        let courseSyncFuture = courses?.map { course in
            return CourseItemHelper.syncCourseItemsWithContent(for: course, withContentType: Video.contentType, networker: self.networker)
        }.sequence().asVoid()

        promise.completeWith(courseSyncFuture ?? Future(value: ()))

        return promise.future
    }

    // Download content (find courses -> find sections -> start downloads)
    private static func downloadNewContent(in context: NSManagedObjectContext, triggeredBy trigger: DownloadTrigger) -> Future<Void, XikoloError> {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        var downloadFutures: [Future<Void, XikoloError>] = []

        courses?.forEach { course in
            guard let automatedDownloadSettings = course.automatedDownloadSettings else { return }
            guard automatedDownloadSettings.newContentAction == .notificationAndBackgroundDownload else { return }

            self.sectionsToDownload(for: course).forEach { section in
                downloadFutures.append(self.downloadContent(of: section, withTypes: automatedDownloadSettings.fileTypes, triggeredBy: trigger))
            }
        }

        return downloadFutures.sequence().asVoid()
    }

    static func sectionsToDownload(for course: Course) -> Set<CourseSection> {
        guard let automatedDownloadSettings = course.automatedDownloadSettings else { return [] }
        guard automatedDownloadSettings.newContentAction == .notificationAndBackgroundDownload else { return [] }

        let orderedStartDates = course.sections.filter { section in
            // Using higher order functions on `section.items` may result in a EXC_BAD_ACCESS error.
            // This behavior was only observed in `sectionToDelete(for:)`. However to be on the
            // safe side (the code is nearly identical), we use an inelegant check here as well.
            for item in section.items {
                // swiftlint:disable:next for_where
                if item.content is Video {
                    return true
                }
            }

            return false
        }.compactMap(\.startsAt).filter(\.inPast).sorted()

        let lastSectionStart = orderedStartDates.last
        let sectionsToDownload = course.sections.filter { section in
            let endDate = section.endsAt ?? course.endsAt
            let endDateInFuture = endDate?.inFuture ?? true
            return section.startsAt == lastSectionStart && endDateInFuture
        }.filter { section in // filter for sections with pending downloads
            // Using higher order functions on `section.items` may result in a EXC_BAD_ACCESS error.
            // This behavior was only observed in `sectionToDelete(for:)`. However to be on the
            // safe side (the code is nearly identical), we use an inelegant check here as well.
            for item in section.items {
                if let video = item.content as? Video {
                    let pendingVideoDownload = StreamPersistenceManager.shared.downloadState(for: video) == .notDownloaded
                    let pendingSlidesDownload = SlidesPersistenceManager.shared.downloadState(for: video) == .notDownloaded
                    if pendingVideoDownload || (automatedDownloadSettings.fileTypes.contains(.slides) && pendingSlidesDownload) {
                        return true
                    }
                }
            }

            return false
        }

        return sectionsToDownload
    }

    static func pendingDownloadsOrDeletionsExist(in context: NSManagedObjectContext) -> Bool {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = context.fetchMultiple(fetchRequest).value ?? []

        for course in courses {
            if !sectionsToDownload(for: course).isEmpty {
                return true
            }

            if !sectionsToDelete(for: course).isEmpty {
                return true
            }
        }

        return false
    }

    // Delete older content (find courses -> find old sections -> delete content)
    private static func deleteOldContent(in context: NSManagedObjectContext) -> Future<Void, XikoloError> {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        var deleteFutures: [Future<Void, XikoloError>] = []

        courses?.forEach { course in
            guard let automatedDownloadSettings = course.automatedDownloadSettings else { return }
            if automatedDownloadSettings.deletionOption == .manual { return }

            self.sectionsToDelete(for: course).forEach { section in
                let deleteStreamFuture = StreamPersistenceManager.shared.deleteDownloads(for: section)
                deleteFutures.append(deleteStreamFuture)

                if automatedDownloadSettings.fileTypes.contains(.slides) {
                    let deleteSlidesFuture = SlidesPersistenceManager.shared.deleteDownloads(for: section)
                    deleteFutures.append(deleteSlidesFuture)
                }
            }
        }

        return deleteFutures.sequence().asVoid()
    }

    static func sectionsToDelete(for course: Course) -> Set<CourseSection> {
        guard let automatedDownloadSettings = course.automatedDownloadSettings else { return [] }
        guard automatedDownloadSettings.newContentAction == .notificationAndBackgroundDownload else { return [] }

        let startDates = Set(course.sections.filter { section in
            // Using higher order functions on `section.items` like ``section.items.map(\.content)`,
            // `section.items.contains { $0.content is Video }` or `section.items.contains { $0.contentType == Video.contentType}`
            // does result in a EXC_BAD_ACCESS error. Might this be a bug in CoreData?
            // Nevertheless, we iterate over the items instead. Until now, this has not failed (but requires some inelegant code).
            for item in section.items {
                // swiftlint:disable:next for_where
                if item.content is Video {
                    return true
                }
            }

            return false
        }.compactMap(\.startsAt).filter(\.inPast))
        let orderedStartDates = Array(startDates).sorted()

        let possibleSectionStartForDeletion: Date? = {
            switch automatedDownloadSettings.deletionOption {
            case .nextSection:
                return orderedStartDates.suffix(1).first
            case .secondNextSection:
                return orderedStartDates.suffix(2).first
            default:
                return nil
            }
        }()

        guard let sectionStartForDeletion = possibleSectionStartForDeletion else { return [] }
        let sectionsToDelete = course.sections.filter {
            (($0.startsAt ?? Date.distantFuture) < sectionStartForDeletion) || (course.endsAt?.inPast ?? false)
        }.filter { section in // filter for sections with existing downloads
            // Using higher order functions on `section.items` may result in a EXC_BAD_ACCESS error.
            // This behavior was only observed in `sectionToDelete(for:)`. However to be on the
            // safe side (the code is nearly identical), we use an inelegant check here as well.
            for item in section.items {
                if let video = item.content as? Video {
                    let existingVideoDownload = StreamPersistenceManager.shared.downloadState(for: video) == .downloaded
                    let existingSlidesDownload = SlidesPersistenceManager.shared.downloadState(for: video) == .downloaded
                    if existingVideoDownload || (automatedDownloadSettings.fileTypes.contains(.slides) && existingSlidesDownload) {
                        return true
                    }
                }
            }

            return false
        }

        return sectionsToDelete
    }

    private static func downloadContent(of section: CourseSection,
                                        withTypes fileTypes: AutomatedDownloadSettings.FileTypes?,
                                        triggeredBy trigger: DownloadTrigger) -> Future<Void, XikoloError> {
        var downloadFutures: [Future<Void, XikoloError>] = []

        let downloadOptions: [StreamPersistenceManager.Option] = [.silent, .trackingContext(trigger.trackingContext)]
        let downloadStreamFuture = StreamPersistenceManager.shared.startDownloads(for: section, options: downloadOptions)
        downloadFutures.append(downloadStreamFuture)

        if fileTypes?.contains(.slides) == true {
            let downloadOptions: [SlidesPersistenceManager.Option] = [.silent, .trackingContext(trigger.trackingContext)]
            let downloadSlidesFuture = SlidesPersistenceManager.shared.startDownloads(for: section, options: downloadOptions)
            downloadFutures.append(downloadSlidesFuture)
        }

        return downloadFutures.sequence().asVoid()
    }

    static func downloadContent(of section: CourseSection, triggeredBy trigger: DownloadTrigger) -> Future<Void, XikoloError> {
        let downloadSettings = section.course?.automatedDownloadSettings
        return self.downloadContent(of: section, withTypes: downloadSettings?.fileTypes, triggeredBy: trigger)
    }

}
