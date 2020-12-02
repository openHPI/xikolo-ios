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
    static let refreshTaskIdentifier = "de.xikolo.ios.background.refresh"
    static let backgroundDownloadTaskIdentifier = "de.xikolo.ios.background.download"

    static func registerBackgroundTask() {
        var result = BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshTaskIdentifier, using: nil) { task in
            self.performRefresh(task: task)
        }

        result = BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundDownloadTaskIdentifier, using: nil) { task in
            self.performNextBackgroundProcessingTasks(task: task)
        }
        
    }


    // - schedule next background task (find next sections/course -> start change date for existing bgtask or cancel | setup new bgtask)
    static func scheduleNextRefreshTask() {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            // Find next date for app refresh
            guard let dateForNextRefresh = self.dateForNextRefresh(in: context) else {
                return
            }

            // Cancel current task requests
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.refreshTaskIdentifier)

            // Setup new task request
            let refreshTaskRequest = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)
            refreshTaskRequest.earliestBeginDate = dateForNextRefresh
            do {
                try BGTaskScheduler.shared.submit(refreshTaskRequest)
            } catch {
                print(error)
            }
        }
    }

    private static func scheduleBackgroundDownload() {
        // Cancel current task requests
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.backgroundDownloadTaskIdentifier)

        // Setup new task request
        let downloadTaskRequest = BGProcessingTaskRequest(identifier: Self.backgroundDownloadTaskIdentifier)
        downloadTaskRequest.requiresNetworkConnectivity = true
        try? BGTaskScheduler.shared.submit(downloadTaskRequest)
    }

    static func dateForNextRefresh(in context: NSManagedObjectContext) -> Date? {
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

    static func performRefresh(task: BGTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        self.scheduleNextRefreshTask()

        let refreshFuture = self.refreshCourseItemsForCoursesWithAutomatedDownloads().onSuccess { _ in
            self.scheduleNextRefreshTask()
            self.postLocalPushNotificationIfApplicable()
            self.scheduleBackgroundDownloadIfApplicable()
        }

        refreshFuture.onComplete { result in
            task.setTaskCompleted(success: result.value != nil)
        }
    }


    // todo old
    static func performNextBackgroundProcessingTasks(task: BGTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        let downloadFuture = self.downloadNewContent()
        let deleteFuture = self.deleteOldContent()
        let processingFuture = downloadFuture.zip(deleteFuture).asVoid()

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
                return CourseItemHelper.syncCourseItemsWithContent(for: course)
            }.sequence().asVoid()

            promise.completeWith(courseSyncFuture ?? Future(value: ()))
        }

        return promise.future
    }

    private static func postLocalPushNotificationIfApplicable() {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let coursesWithNotificationsAndNewContent = self.coursesWithNotificationsAndNewContent(in: context)
            guard !coursesWithNotificationsAndNewContent.isEmpty else { return }

            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                center.add(XikoloNotification.automatedDownloadsNotificationRequest)
            }
        }
    }

    private static func scheduleBackgroundDownloadIfApplicable() {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
            let courses = (try? context.fetch(fetchRequest)) ?? []

            let courseWithAvailableBackgroundDownload = courses.filter { course in
                guard course.automatedDownloadSettings?.downloadOption == .backgroundDownload else { return false }
                return !self.sectionsToDownload(for: course).isEmpty || !self.sectionsToDelete(for: course).isEmpty
            }

            if !courseWithAvailableBackgroundDownload.isEmpty {
                self.scheduleBackgroundDownload()
            }
        }
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
