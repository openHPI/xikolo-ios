//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BackgroundTasks
import BrightFutures
import Common
import CoreData
import UserNotifications

@available(iOS 13, *)
enum AutomatedDownloadsManager {

    static let taskIdentifier = "de.xikolo.ios.background.download"
    static let urlSessionIdentifier = "de.xikolo.ios.background.download.sync"

    static let networker = XikoloBackgroundNetworker(withIdentifier: Self.urlSessionIdentifier, backgroundCompletionHandler: {
        Self.backgroundCompletionHandler?()
    })
    static var backgroundCompletionHandler: (() -> Void)?

    static func registerBackgroundTask() {
        #warning("Use non-default bg queue?")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.performNextBackgroundProcessingTasks(task: task)
        }
    }


    // - schedule next background task (find next sections/course -> start change date for existing bg task or cancel | setup new bgtask)
    static func scheduleNextBackgroundProcessingTask() {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
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
            do {
                try BGTaskScheduler.shared.submit(automatedDownloadTaskRequest)
                self.debugLog("""
                \(ISO8601DateFormatter().string(from: Date()))
                Schedule BG task for \(ISO8601DateFormatter().string(from: dateForNextBackgroundProcessing))

                """)
            } catch {
                self.debugLog("""
                \(ISO8601DateFormatter().string(from: Date()))
                Error while scheduling BG task for \(ISO8601DateFormatter().string(from: dateForNextBackgroundProcessing)):
                \(error)

                """)
            }
        }
    }

    static func dateForNextBackgroundProcessing(in context: NSManagedObjectContext) -> Date? {
        #warning("Change this back")
        return Date()

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
        task.expirationHandler = {
            self.debugLog("""
            \(ISO8601DateFormatter().string(from: Date()))
            BG task expired

            """)
            task.setTaskCompleted(success: false)
            StreamPersistenceManager.shared.persistentContainerQueue.cancelAllOperations()
            StreamPersistenceManager.shared.session.invalidateAndCancel()
            SlidesPersistenceManager.shared.persistentContainerQueue.cancelAllOperations()
            SlidesPersistenceManager.shared.session.invalidateAndCancel()
        }

        self.debugLog("""
        \(ISO8601DateFormatter().string(from: Date()))
        BG task started

        """)

        self.scheduleNextBackgroundProcessingTask()

        let refreshFuture = self.refreshCourseItemsForCoursesWithAutomatedDownloads().onComplete { _ in
            self.scheduleNextBackgroundProcessingTask()
        }

        let processingFuture = refreshFuture.flatMap { _ -> Future<Void, XikoloError> in
            let downloadFuture = self.downloadNewContent(in: CoreDataHelper.persistentContainer.newBackgroundContext())
            let deleteFuture = self.deleteOldContent()
            return [downloadFuture, deleteFuture].sequence().asVoid()
        }

        processingFuture.onComplete { result in
            self.debugLog("""
            \(ISO8601DateFormatter().string(from: Date()))
            BG task completed (result: \(result.value != nil))

            """)
            task.setTaskCompleted(success: result.value != nil)
        }
    }

    private static func refreshCourseItemsForCoursesWithAutomatedDownloads() -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
            let courses = try? context.fetch(fetchRequest)

            let courseSyncFuture = courses?.map { course in
                return CourseItemHelper.syncCourseItemsWithContent(for: course, withContentType: Video.contentType, networker: self.networker)
            }.sequence().asVoid()

            promise.completeWith(courseSyncFuture ?? Future(value: ()))
        }

        return promise.future
    }

    // Download content (find courses -> find sections -> start downloads)
    @discardableResult
    static func downloadNewContent() -> Future<Void, XikoloError> {
        #warning("TODO: background or view context")
//        return CoreDataHelper.persistentContainer.performBackgroundTask { context in
//            return self.downloadNewContentFuture(in: context)
//        }
        return downloadNewContent(in: CoreDataHelper.viewContext)
    }


    static func downloadNewContent(in context: NSManagedObjectContext) -> Future<Void, XikoloError> {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        var downloadFutures: [Future<Void, XikoloError>] = []

        courses?.forEach { course in
            guard let automatedDownloadSettings = course.automatedDownloadSettings else { return }
            guard automatedDownloadSettings.newContentAction == .notificationAndBackgroundDownload else { return }

            self.sectionsToDownload(for: course).forEach { section in
                downloadFutures.append(self.downloadContent(of: section, withTypes: automatedDownloadSettings.fileTypes))
            }
        }

        return downloadFutures.sequence().asVoid()
    }

    static func sectionsToDownload(for course: Course) -> Set<CourseSection> {
        let orderedStartDates = course.sections.compactMap(\.startsAt).filter(\.inPast).sorted()

        let lastSectionStart = orderedStartDates.last
        let sectionsToDownload = course.sections.filter { section in
            let endDate = section.endsAt ?? course.endsAt
            let endDateInFuture = endDate?.inFuture ?? true
            return section.startsAt == lastSectionStart && endDateInFuture
        }

        return sectionsToDownload
    }

    static func deleteOldContent() -> Future<Void, XikoloError> {
        #warning("TODO: background or view context. StreamPersistenceManager.shared.startDownloads uses separate coredata context")

//        return CoreDataHelper.persistentContainer.performBackgroundTask { context in
//            return self.deleteOldContent(in: context)
//        }

        return self.deleteOldContent(in: CoreDataHelper.viewContext)
    }

    // Delete older content (find courses -> find old sections -> delete content)
    static func deleteOldContent(in context: NSManagedObjectContext) -> Future<Void, XikoloError> {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        var deleteFutures: [Future<Void, XikoloError>] = []

        courses?.forEach { course in
            guard let automatedDownloadSettings = course.automatedDownloadSettings else { return }
            if automatedDownloadSettings.deletionOption == .manual { return }

            self.sectionsToDelete(for: course).forEach { section in
//                let section: CourseSection = context.typedObject(with: backgroundSection.objectID)

//                context.refresh(section, mergeChanges: true)
//                let section: CourseSection = CoreDataHelper.viewContext.typedObject(with: backgroundSection.objectID)
//                section.willAccessValue(forKey: nil)
//                section.items.forEach {
//                    $0.willAccessValue(forKey: nil)
//                    $0.content?.willAccessValue(forKey: nil)
//                }
                let deleteStreamFuture = StreamPersistenceManager.shared.deleteDownloads(for: section)
                deleteFutures.append(deleteStreamFuture)

                if automatedDownloadSettings.fileTypes.contains(.slides)  {
                    let deleteSlidesFuture = SlidesPersistenceManager.shared.deleteDownloads(for: section)
                    deleteFutures.append(deleteSlidesFuture)
                }
            }
        }

        return deleteFutures.sequence().asVoid()
    }

    static func sectionsToDelete(for course: Course) -> Set<CourseSection> {
        let orderedStartDates = course.sections.compactMap(\.endsAt).filter(\.inPast).sorted()

        let possibleSectionEndForDeletion: Date? = {
            switch course.automatedDownloadSettings?.deletionOption {
            case .nextSection:
                return orderedStartDates.suffix(1).first
            case .secondNextSection:
                return orderedStartDates.suffix(2).first
            default:
                return nil
            }
        }()

        guard let sectionEndForDeletion = possibleSectionEndForDeletion else { return [] }
        let sectionsToDelete = course.sections.filter {
            (($0.endsAt ?? Date.distantFuture) <= sectionEndForDeletion) || (course.endsAt?.inPast ?? false)
        }

        return sectionsToDelete
    }

    static func downloadContent(of section: CourseSection, withTypes fileTypes: AutomatedDownloadSettings.FileTypes?) -> Future<Void, XikoloError> {
        var downloadFutures: [Future<Void, XikoloError>] = []

//                let section: CourseSection = context.typedObject(with: backgroundSection.objectID)
//                context.refresh(section, mergeChanges: true)
//                section.items.forEach { context.refresh($0, mergeChanges: true) }
//                section.willAccessValue(forKey: nil)
//                section.items.forEach {
//                    $0.willAccessValue(forKey: nil)
//                    $0.content?.willAccessValue(forKey: nil)
//                }

        let downloadStreamFuture = StreamPersistenceManager.shared.startDownloads(for: section)
        downloadFutures.append(downloadStreamFuture)

        if fileTypes?.contains(.slides) == true {
            let downloadSlidesFuture = SlidesPersistenceManager.shared.startDownloads(for: section)
            downloadFutures.append(downloadSlidesFuture)
        }

        return downloadFutures.sequence().asVoid()
    }

    static func downloadContent(of section: CourseSection) -> Future<Void, XikoloError> {
        let downloadSettings = section.course?.automatedDownloadSettings
        return self.downloadContent(of: section, withTypes: downloadSettings?.fileTypes)
    }

    static var debugBackgroundDownload: String {
        get {
            return UserDefaults.standard.string(forKey: "debug.background.download") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "debug.background.download")
        }
    }

    static func debugLog(_ text: String) {
        self.debugBackgroundDownload = text + self.debugBackgroundDownload
    }

}


extension NSPersistentContainer {

    func performBackgroundTask<U, E>(_ block: @escaping (NSManagedObjectContext) -> Future<U, E>) -> Future<U, E> {
        let promise = Promise<U, E>()

        self.performBackgroundTask { context in
            let future = block(context)
            promise.completeWith(future)
        }

        return promise.future
    }

}
