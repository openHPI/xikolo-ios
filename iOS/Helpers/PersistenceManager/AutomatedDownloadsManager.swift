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

    private static let lastDownloadKey = "de.xikolo.ios.background.download.last-date"
    static let taskIdentifier = "de.xikolo.ios.background.download"
    static let urlSessionIdentifier = "de.xikolo.ios.background.download.sync"

    static let networker = XikoloBackgroundNetworker(withIdentifier: Self.urlSessionIdentifier)

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.performNextBackgroundProcessingTasks(task: task)
        }
    }

    // - schedule next background task (find next sections/course -> start change date for existing bgtask or cancel | setup new bgtask)
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
            try? BGTaskScheduler.shared.submit(automatedDownloadTaskRequest)
        }
    }

    static func dateForNextBackgroundProcessing(in context: NSManagedObjectContext) -> Date? {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)
        let nextDates: [Date]? = courses?.compactMap { course -> Date? in
            let courseDates = [course.startsAt, course.endsAt].compactMap { $0 }
            let sectionDates = course.sections.compactMap(\.startsAt)
            let dates = sectionDates + courseDates
            return dates.filter(\.inFuture).min()
        }

        return nextDates?.min()
    }

    static func performNextBackgroundProcessingTasks(task: BGTask) {
        self.scheduleNextBackgroundProcessingTask()

        let refreshFuture = self.refreshCourseItemsForCoursesWithAutomatedDownloads().onComplete { _ in
            self.scheduleNextBackgroundProcessingTask()
        }

        let processingFuture = refreshFuture.flatMap { _ -> Future<Void, XikoloError> in
            let notificationFuture = self.postLocalPushNotificationIfApplicable()
            let downloadFuture = self.downloadNewContent()
            let deleteFuture = self.deleteOldContent()
            return downloadFuture.zip(deleteFuture).zip(notificationFuture.promoteError()).asVoid()
        }

        processingFuture.onComplete { result in
            task.setTaskCompleted(success: result.value != nil)
        }
    }

    private static func refreshCourseItemsForCoursesWithAutomatedDownloads() -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
            let courses = try? context.fetch(fetchRequest)

            let courseSyncFuture = courses?.map { course in
                return CourseItemHelper.backgroundSyncCourseItemsWithContent(for: course, networker: self.networker)
            }.sequence().asVoid()

            promise.completeWith(courseSyncFuture ?? Future(value: ()))
        }

        return promise.future
    }

    private static func postLocalPushNotificationIfApplicable() -> Future<Void, Never> {
        let promise = Promise<Void, Never>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let coursesWithNotificationsAndNewContent = self.coursesWithNotificationsAndNewContent(in: context)
            if !coursesWithNotificationsAndNewContent.isEmpty {
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized {
                        center.add(XikoloNotification.automatedDownloadsNotificationRequest)
                    }
                }
            }

            promise.success(())
        }

        return promise.future
    }

    @discardableResult
    static func downloadNewContent(ignoreDownloadOption: Bool = false) -> Future<Void, XikoloError> {
        return CoreDataHelper.persistentContainer.performBackgroundTask { context in
            return self.downloadNewContentFuture(in: context, ignoreDownloadOption: ignoreDownloadOption)
        }
    }

    // Download content (find courses -> find sections -> start downloads)
    static func downloadNewContentFuture(in context: NSManagedObjectContext, ignoreDownloadOption: Bool) -> Future<Void, XikoloError> {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        var downloadFutures: [Future<Void, XikoloError>] = []

        courses?.forEach { course in
            guard course.automatedDownloadSettings?.downloadOption == .backgroundDownload || ignoreDownloadOption else { return }
            guard let materialsToDownload = course.automatedDownloadSettings?.materialTypes else { return }

            self.sectionsToDownload(for: course).forEach { backgroundSection in
                let section: CourseSection = CoreDataHelper.viewContext.typedObject(with: backgroundSection.objectID)
                if materialsToDownload.contains(.videos) {
                    let downloadStreamFuture = StreamPersistenceManager.shared.startDownloads(for: section)
                    downloadFutures.append(downloadStreamFuture)
                }

                if materialsToDownload.contains(.slides) {
                    let downloadSlidesFuture = SlidesPersistenceManager.shared.startDownloads(for: section)
                    downloadFutures.append(downloadSlidesFuture)
                }
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
        return CoreDataHelper.persistentContainer.performBackgroundTask { context in
            return self.deleteOldContent(in: context)
        }
    }

    // Delete older content (find courses -> find old sections -> delete content)
    static func deleteOldContent(in context: NSManagedObjectContext) -> Future<Void, XikoloError> {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        var deleteFutures: [Future<Void, XikoloError>] = []

        courses?.forEach { course in
            guard let materialsToDownload = course.automatedDownloadSettings?.materialTypes else { return }
            if course.automatedDownloadSettings?.deletionOption == .manual { return }

            self.sectionsToDelete(for: course).forEach { backgroundSection in
                let section: CourseSection = CoreDataHelper.viewContext.typedObject(with: backgroundSection.objectID)
                if materialsToDownload.contains(.videos) {
                    let downloadStreamFuture = StreamPersistenceManager.shared.startDownloads(for: section)
                    deleteFutures.append(downloadStreamFuture)
                }

                if materialsToDownload.contains(.slides) {
                    let downloadSlidesFuture = SlidesPersistenceManager.shared.startDownloads(for: section)
                    deleteFutures.append(downloadSlidesFuture)
                }
            }
        }

        return deleteFutures.sequence().asVoid()
    }

    static func sectionsToDelete(for course: Course) -> Set<CourseSection> {
        let orderedStartDates = course.sections.compactMap(\.startsAt).filter(\.inPast).sorted()

        let possibleSectionStartForDeletion: Date? = {
            switch course.automatedDownloadSettings?.deletionOption {
            case .nextSection:
                return orderedStartDates.suffix(2).first
            case .secondNextSection:
                return orderedStartDates.suffix(3).first
            default:
                return nil
            }
        }()

        guard let sectionStartForDeletion = possibleSectionStartForDeletion else { return [] }
        let sectionsToDelete = course.sections.filter {
            ($0.startsAt == sectionStartForDeletion && $0.endsAt?.inPast ?? false) || course.endsAt?.inPast ?? false
        }

        return sectionsToDelete
    }

    static func coursesWithNotificationsAndNewContent(in context: NSManagedObjectContext) -> [Course] {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)
        let coursesWithNotification = courses?.filter { course in
            return course.automatedDownloadSettings?.downloadOption == .notification
        }

        let coursesWithNotificationAndNewContent = coursesWithNotification?.filter { course in
            let sectionStartDates = course.sections.compactMap(\.startsAt)
            let newSectionStartDates = sectionStartDates.map{ $0 > self.lastAutomatedDownloadDate  }
            return !newSectionStartDates.isEmpty
        }

        return coursesWithNotificationAndNewContent ?? []
    }

    static var lastAutomatedDownloadDate: Date {
        get {
            return UserDefaults.standard.object(forKey: self.lastDownloadKey) as? Date ?? Date.distantPast
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.lastDownloadKey)
        }
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
