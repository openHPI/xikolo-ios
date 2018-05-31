//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

final class SlidesPersistenceManager: NSObject, FilePersistenceManager {

    //    typealias Resource = Video

    static var shared = SlidesPersistenceManager(keyPath: \Video.localFileBookmark) /// XXX: Change keypath

    lazy var persistentContainerQueue = self.createPersistenceContainerQueue()
    lazy var session: URLSession = self.createURLSession(withIdentifier: "slides-download")

    var activeDownloads: [URLSessionTask: String] = [:]
    var progresses: [String: Double] = [:]
    var didRestorePersistenceManager: Bool = false

    var keyPath: ReferenceWritableKeyPath<Video, NSData?>

    init(keyPath: ReferenceWritableKeyPath<Video, NSData?>) {
        self.keyPath = keyPath
        super.init()
        self.startListeningToDownloadProgressChanges()
    }

}
