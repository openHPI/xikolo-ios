//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol FilePersistenceManager: PersistenceManager, URLSessionDelegate {

    func createURLSession(withIdentifier identifier: String) -> URLSession

}

extension FilePersistenceManager {

    func createURLSession(withIdentifier identifier: String) -> URLSession {
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        return URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    }

    func downloadTask(with url: URL, for resource: Resource, on session: Session) -> URLSessionTask? {
        return session.downloadTask(with: url)
    }

}

extension FilePersistenceManager {
//    func urlSession(_ session: URLSession,
//                    task: URLSessionTask,
//                    didCompleteWithError error: Error?) {}
//
//    func urlSession(_ session: URLSession,
//                    assetDownloadTask: AVAssetDownloadTask,
//                    didFinishDownloadingTo location: URL) {}
//
//    func urlSession(_ session: URLSession,
//                    assetDownloadTask: AVAssetDownloadTask,
//                    didLoad timeRange: CMTimeRange,
//                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
//                    timeRangeExpectedToLoad: CMTimeRange) {}
}
