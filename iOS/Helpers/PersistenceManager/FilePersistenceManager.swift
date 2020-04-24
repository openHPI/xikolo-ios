//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

class FilePersistenceManager<Configuration: PersistenceManagerConfiguration>: PersistenceManager<Configuration>, URLSessionDownloadDelegate {

    func createURLSession(withIdentifier identifier: String) -> URLSession {
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        return URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }

    override func downloadTask(with url: URL, for resource: Resource, on session: Session) -> URLSessionTask? {
        return session.downloadTask(with: url)
    }

    override func fileSize(for resource: Resource) -> UInt64? {
        guard let url = localFileLocation(for: resource) else { return nil }
        return try? url.regularFileAllocatedSize()
    }

    // MARK: URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.didCompleteDownloadTask(task, with: error)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else { return }
        guard let fileName = downloadTask.originalRequest?.url?.lastPathComponent else { return }
        guard let contentId = downloadTask.taskDescription else { return }

        let documentLocation = documentsDirectory.appendingPathComponent(Configuration.downloadType + "_" + contentId + "_" + fileName)

        do {
            if FileManager.default.fileExists(atPath: documentLocation.path) {
                try FileManager.default.removeItem(at: documentLocation)
            }

            try FileManager.default.moveItem(at: location, to: documentLocation)
            self.didFinishDownloadTask(downloadTask, to: documentLocation)
        } catch {
            log.error("Failed to move downloaded file to documents directory: \(error)")
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let resourceId = self.activeDownloads[downloadTask] else { return }

        let percentComplete = max(0.0, min(1.0, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))

        var userInfo: [String: Any] = [:]
        userInfo[DownloadNotificationKey.downloadType] = Configuration.downloadType
        userInfo[DownloadNotificationKey.resourceId] = resourceId
        userInfo[DownloadNotificationKey.downloadProgress] = percentComplete

        NotificationCenter.default.post(name: DownloadProgress.didChangeNotification, object: nil, userInfo: userInfo)
    }

}
