//
//  Video.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 30.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import AVFoundation
import BrightFutures
import CoreData
import Foundation

final class Video : Content {

    @NSManaged var id: String
    @NSManaged var audioSize: Int32
    @NSManaged var audioURL: URL?
    @NSManaged var downloadDate: Date?
    @NSManaged var duration: Int32
    @NSManaged var lecturerStream: VideoStream?
    @NSManaged var localFileBookmark: NSData?
    @NSManaged var singleStream: VideoStream?
    @NSManaged var slidesSize: Int32
    @NSManaged var slidesStream: VideoStream?
    @NSManaged var slidesURL: URL?
    @NSManaged var summary: String?
    @NSManaged var thumbnailURL: URL?
    @NSManaged var transcriptSize: Int32
    @NSManaged var transcriptURL: URL?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video");
    }

    var posterImageData: Data? {
        if let posterImageURL = self.singleStream?.thumbnailURL {
            do {
                return try Data(contentsOf: posterImageURL)
            } catch {
                print("Failed to load poster image")
            }
        }
        return nil
    }

    func metadata() -> [AVMetadataItem] {
        var items: [AVMetadataItem] = []
        if let course_item = self.item, let item = AVMetadataItem.item(AVMetadataIdentifier.commonIdentifierTitle, value: course_item.title) {
            items.append(item)
        }
        if let item = AVMetadataItem.item(AVMetadataIdentifier.commonIdentifierDescription, value: summary) {
            items.append(item)
        }
        return items
    }

    override var isAvailableOffline: Bool {
        return self.localFileBookmark != nil
    }

}

extension Video : Pullable {

    static var type: String {
        return "videos"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
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
