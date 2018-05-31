//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol FilePersistenceManager: PersistenceManager, URLSessionDownloadDelegate {

    func createURLSession(withIdentifier identifier: String) -> URLSession

    func downloadTask(_ task: URLSessionTask, didCompleteWithError error: Error?)
    func downloadTask(_ task: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    func downloadTask(_ task: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)

}

extension FilePersistenceManager {

    func createURLSession(withIdentifier identifier: String) -> URLSession {
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        return URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }

    func downloadTask(with url: URL, for resource: Resource, on session: Session) -> URLSessionTask? {
        return session.downloadTask(with: url)
    }

    func downloadTask(_ task: URLSessionTask, didCompleteWithError error: Error?) {
        self.didCompleteDownloadTask(task, with: error)
    }

    func downloadTask(_ task: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.didFinishDownloadTask(task, to: location)
    }

    func downloadTask(_ task: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let resourceId = self.activeDownloads[task] else { return }

        let percentComplete = max(0.0, min(1.0, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))

        var userInfo: [String: Any] = [:]
        userInfo[DownloadNotificationKey.type] = Resource.type
        userInfo[DownloadNotificationKey.id] = resourceId
        userInfo[DownloadNotificationKey.downloadProgress] = percentComplete

        NotificationCenter.default.post(name: NotificationKeys.DownloadProgressDidChange, object: nil, userInfo: userInfo)
    }

}
