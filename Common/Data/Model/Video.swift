//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import BrightFutures
import CoreData
import Foundation
import SyncEngine

public final class Video: Content {

    @NSManaged public var id: String
    @NSManaged public var audioSize: Int32
    @NSManaged public var audioURL: URL?
    @NSManaged public var downloadDate: Date?
    @NSManaged public var duration: Int32
    @NSManaged public var lecturerStream: VideoStream?
    @NSManaged public var localFileBookmark: NSData?
    @NSManaged public var localSlidesBookmark: NSData?
    @NSManaged public var singleStream: VideoStream?
    @NSManaged public var slidesSize: Int32
    @NSManaged public var slidesStream: VideoStream?
    @NSManaged public var slidesURL: URL?
    @NSManaged public var summary: String?
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var transcriptSize: Int32
    @NSManaged public var transcriptURL: URL?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    public var posterImageData: Data? {
        if let posterImageURL = self.singleStream?.thumbnailURL {
            do {
                return try Data(contentsOf: posterImageURL)
            } catch {
                log.warning("Failed to load poster image")
            }
        }

        return nil
    }

    override public var isAvailableOffline: Bool {
        return self.localFileBookmark != nil || self.localSlidesBookmark != nil
    }

}

extension Video: JSONAPIPullable {

    public static var type: String {
        return "videos"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.audioSize = try attributes.value(for: "audio_size")
        self.audioURL = try attributes.value(for: "audio_url")
        self.duration = try attributes.value(for: "duration")
        self.lecturerStream = try attributes.value(for: "lecturer_stream")
        self.singleStream = try attributes.value(for: "single_stream")
        self.slidesSize = try attributes.value(for: "slides_size")
        self.slidesStream = try attributes.value(for: "slides_stream")
        self.slidesURL = try attributes.value(for: "slides_url")
        self.summary = try attributes.value(for: "summary")
        self.thumbnailURL = try attributes.value(for: "thumbnail_url")
        self.transcriptURL = try attributes.value(for: "transcript_url")
        self.transcriptSize = try attributes.value(for: "transcript_size")
    }

}
