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
import Spine

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

//    var audioURL: URL? {
//        get {
//            guard let value = self.audioURLString else { return nil }
//            return URL(string: value)
//        }
//        set {
//            self.audioURLString = newValue?.absoluteString
//        }
//    }
//
//    var slidesURL: URL? {
//        get {
//            guard let value = self.slidesURLString else { return nil }
//            return URL(string: value)
//        }
//        set {
//            self.slidesURLString = newValue?.absoluteString
//        }
//    }

//    var thumbnailURL: URL? {
//        get {
//            guard let value = self.thumbnailURLString else { return nil }
//            return URL(string: value)
//        }
//        set {
//            self.thumbnailURLString = newValue?.absoluteString
//        }
//    }
//
//    var transcriptURL: URL? {
//        get {
//            guard let value = self.transcriptURLString else { return nil }
//            return URL(string: value)
//        }
//        set {
//            self.transcriptURLString = newValue?.absoluteString
//        }
//    }

    override func iconName() -> String {
        return "video"
    }

//    var hlsURL: URL? {
//        guard let urlString = self.singleStream?.hlsURL else {
//            return nil
//        }
//        return URL(string: urlString)
//    }

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





//@objcMembers
//class VideoSpine : ContentSpine {
//
//    var summary: String?
//    var duration: NSNumber?
//
//    var slides_url: URL?
//    var audio_url: URL?
//    var transcript_url: URL?
//    var thumbnail_url: URL?
//
//    var slides_size: NSNumber?
//    var audio_size: NSNumber?
//    var transcript_size: NSNumber?
//
//    var single_stream: VideoStreamSpine?
//    var lecturer_stream: VideoStreamSpine?
//    var slides_stream: VideoStreamSpine?
//
//    override class var cdType: BaseModel.Type {
//        return Video.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "videos"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "summary": Attribute(),
//            "duration": Attribute(),
//            "slides_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
//            "slides_size": Attribute(),
//            "audio_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
//            "audio_size": Attribute(),
//            "transcript_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
//            "transcript_size": Attribute(),
//            "thumbnail_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
//            "single_stream": VideoStreamAttribute(prefix: "single_stream"),
//            "lecturer_stream": VideoStreamAttribute(prefix: "lecturer_stream"),
//            "slides_stream": VideoStreamAttribute(prefix: "slides_stream"),
//        ])
//    }
//
//}
//
//class VideoStreamSpine : CompoundValue {
//
//    let prefix: String
//    var hls_url: String?
//    var thumbnail_url: String?
//
//    init(_ dict: [String: AnyObject]?, withPrefix prefix: String) {
//        self.prefix = prefix
//        if let dict = dict {
//            self.hls_url = dict["hls_url"] as? String
//            self.thumbnail_url = dict["thumbnail_url"] as? String
//        }
//    }
//
//    override func saveToCoreData(model: BaseModel) {
//        let p = prefix + "_"
//        model.setValue(hls_url, forKey: p + "hls_url")
//        model.setValue(thumbnail_url, forKey: p + "thumbnail_url")
//    }
//
//}
//
//class VideoStreamAttribute : CompoundAttribute {
//
//    let prefix: String
//
//    public init(prefix: String) {
//        self.prefix = prefix
//    }
//
//}
//
//struct VideoStreamFormatter : ValueFormatter {
//    typealias FormattedType = [String: AnyObject]
//    typealias UnformattedType = VideoStreamSpine
//    typealias AttributeType = VideoStreamAttribute
//
//    func unformatValue(_ value: FormattedType, forAttribute: AttributeType) -> UnformattedType {
//        return VideoStreamSpine(value, withPrefix: forAttribute.prefix)
//    }
//
//    func formatValue(_ value: UnformattedType, forAttribute: AttributeType) -> FormattedType {
//        // Implement in case we need it.
//        return [:]
//    }
//
//}

