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

    static let networker = XikoloBackgroundNetworker(withIdentifier: Self.urlSessionIdentifier, backgroundCompletionHandler: {
        Self.backgroundCompletionHandler?()
    })
    static var backgroundCompletionHandler: (() -> Void)?

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.performNextBackgroundProcessingTasks(task: task)
        }
    }

    // - schedule next background task (find next sections/course -> start change date for existing bgtask or cancel | setup new bgtask)
    static func scheduleNextBackgroundProcessingTask() {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            // Find next date for background processing
//            guard let dateForNextBackgroundProcessing = self.dateForNextBackgroundProcessing(in: context) else {
//                return
//            }
            let dateForNextBackgroundProcessing = Date()
            // todo

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
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        self.scheduleNextBackgroundProcessingTask()

        let refreshFuture = self.refreshCourseItemsForCoursesWithAutomatedDownloads().onComplete { _ in
            self.scheduleNextBackgroundProcessingTask()
        }

        let processingFuture = refreshFuture.andThen { _ in
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                self.postLocalPushNotificationIfApplicable(in: context)
                self.downloadNewContent(in: context)
                self.deleteOldContent(in: context)
            }
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

    private static func postLocalPushNotificationIfApplicable(in context: NSManagedObjectContext) {
        let coursesWithNotificationsAndNewContent = self.coursesWithNotificationsAndNewContent(in: context)
        if !coursesWithNotificationsAndNewContent.isEmpty {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    center.add(XikoloNotification.automatedDownloadsNotificationRequest)
                }
            }
        }
    }

    // Download content (find courses -> find sections -> start downloads)
    static func downloadNewContent(in context: NSManagedObjectContext, ignoreDownloadOption: Bool = false) {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        courses?.forEach { course in
            guard course.automatedDownloadSettings?.downloadOption == .backgroundDownload || ignoreDownloadOption else { return }
            guard let materialsToDownload = course.automatedDownloadSettings?.materialTypes else { return }

            self.sectionsToDownload(for: course).forEach { section in
                if materialsToDownload.contains(.videos) {
                    section.items.compactMap { item in
                        return item.content as? Video
                    }.filter { video in
                        return StreamPersistenceManager.shared.downloadState(for: video) == .notDownloaded
                    }.forEach { video in
                        StreamPersistenceManager.shared.startDownload(for: video)
                    }
                }

                if materialsToDownload.contains(.slides) {
                    section.items.compactMap { item in
                        return item.content as? Video
                    }.filter { video in
                        return SlidesPersistenceManager.shared.downloadState(for: video) == .notDownloaded
                    }.forEach { video in
                        SlidesPersistenceManager.shared.startDownload(for: video)
                    }
                }
            }
        }
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

    // Delete older content (find courses -> find old sections -> delete content)
    static func deleteOldContent(in context: NSManagedObjectContext) {
        let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let courses = try? context.fetch(fetchRequest)

        courses?.forEach { course in
            guard let materialsToDownload = course.automatedDownloadSettings?.materialTypes else { return }
            if course.automatedDownloadSettings?.deletionOption == .manual { return }

            self.sectionsToDelete(for: course).forEach { section in
                if materialsToDownload.contains(.videos) {
                    section.items.compactMap { item in
                        return item.content as? Video
                    }.forEach { video in
                        StreamPersistenceManager.shared.deleteDownload(for: video)
                    }
                }

                if materialsToDownload.contains(.slides) {
                    section.items.compactMap { item in
                        return item.content as? Video
                    }.forEach { video in
                        SlidesPersistenceManager.shared.deleteDownload(for: video)
                    }
                }
            }
        }
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
