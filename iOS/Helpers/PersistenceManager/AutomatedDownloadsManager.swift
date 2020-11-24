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

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.performNextBackgroundProcessingTasks(task: task)
        }
    }

    // - schedule next background task (find next sections/course -> start change date for existing bgtask or cancel | setup new bgtask)
    static func scheduleNextBackgroundProcessingTask() {
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            // Find next date for background processing
            let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
            let courses = try? context.fetch(fetchRequest)
            let nextDates = courses?.compactMap { course -> Date? in
                let dates = course.sections.compactMap(\.startsAt) + [course.startsAt, course.endsAt].compactMap { $0 }
                let filteredDates = dates.filter { $0 > Date() }
                return filteredDates.min()
            }

            guard let dateForNextBackgroundProcessing = nextDates?.min() else {
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
            } catch {
              print("Unable to submit task: \(error.localizedDescription)")
            }
        }
    }

    static func performNextBackgroundProcessingTasks(task: BGTask) {
        let refreshFuture = self.refreshCourseItemsForCoursesWithAutomatedDownloads().onComplete { _ in
            self.scheduleNextBackgroundProcessingTask()
        }

        let downloadFuture = refreshFuture.flatMap { _ -> Future<Void, XikoloError> in
            self.postLocalPushNotificationIfApplicable()
            let downloadFuture = self.downloadNewContent()
            // TODO: delete old content
            return downloadFuture
        }

        downloadFuture.onComplete { result in
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
            let coursesWithNotificationsAndNewContent = self.coursesWithNotificationsAndNewContent(for: context)
            guard !coursesWithNotificationsAndNewContent.isEmpty else { return }

            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                center.add(XikoloNotification.automatedDownloadsNotificationRequest)
            }
        }
    }

    // Download content (find courses -> find sections -> start downloads)
    // Delete older content (find courses -> find old sections -> delete content)
    @discardableResult
    static func downloadNewContent() -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
            let courses = try? context.fetch(fetchRequest)

            var downloadFutures: [Future<Void, XikoloError>] = []

            courses?.forEach { course in
                if course.automatedDownloadSettings?.downloadOption == .backgroundDownload {
                    if let materialsToDownload = course.automatedDownloadSettings?.materialTypes {
                        // Find all course sections with the latest start date (which can be nil)
                        let orderedSections = course.sections.filter {
                            ($0.startsAt ?? Date.distantPast) < Date()
                        }.sorted {
                            ($0.startsAt ?? Date.distantPast) < ($1.startsAt ?? Date.distantPast)
                        }

                        let lastSectionStart = orderedSections.last?.startsAt
                        let sectionsToDownload = orderedSections.filter { $0.startsAt == lastSectionStart }

                        // TODO: section have no items
                        sectionsToDownload.forEach { backgroundSection in
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
                }
            }

            let combinedDownloadFuture = downloadFutures.sequence().asVoid()
            promise.completeWith(combinedDownloadFuture)
        }

        return promise.future
    }

    static func coursesWithNotificationsAndNewContent(for context: NSManagedObjectContext) -> [Course] {
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
