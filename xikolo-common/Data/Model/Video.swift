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

class Video : Content {

    var poster: UIImage?
    
    override func iconName() -> String {
        return "video"
    }

    func loadPoster() -> Future<Void, XikoloError> {
        if let url = single_stream_poster_url {
            return ImageProvider.loadImage(url).onSuccess { image in
                self.poster = image
            }.map { _ in
            }
        }
        let promise = Promise<Void, XikoloError>()
        promise.success()
        return promise.future
    }

    func metadata() -> [AVMetadataItem] {
        var items: [AVMetadataItem] = []
        if let course_item = self.item, item = AVMetadataItem.item(AVMetadataCommonIdentifierTitle, value: course_item.title) {
            items.append(item)
        }
        if let item = AVMetadataItem.item(AVMetadataCommonIdentifierDescription, value: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea reb") {
            items.append(item)
        }
        if let poster = poster, item = AVMetadataItem.artworkItem(poster) {
            items.append(item)
        }
        return items
    }

}

class VideoSpine : ContentSpine {

    var video_description: String?
    var duration: NSNumber?

    var audio_url: String?
    var subtitles_url: String?
    var transcript_url: String?
    var slides_url: String?

    var single_stream: VideoStreamSpine?
    var dual_stream: DualStreamSpine?

    override class var cdType: BaseModel.Type {
        return Video.self
    }

    override class var resourceType: ResourceType {
        return "videos"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "video_description": Attribute().serializeAs("description"),
            "duration": Attribute(),
            "audio_url": Attribute(),
            "subtitles_url": Attribute(),
            "transcript_url": Attribute(),
            "slides_url": Attribute(),
            "single_stream": VideoStreamAttribute(),
            "dual_stream": DualStreamAttribute(),
        ])
    }

}

class VideoStreamSpine : CompoundValue {

    var hls_url: String?
    var poster_url: String?

    init(_ dict: [String: AnyObject]?) {
        if let dict = dict {
            self.hls_url = dict["hls_url"] as? String
            self.poster_url = dict["poster_image_url"] as? String
        }
    }

    override func saveToCoreData(model: BaseModel) {
        self.saveToCoreData(model, withPrefix: "single_stream")
    }

    func saveToCoreData(model: BaseModel, withPrefix prefix: String) {
        let p = prefix + "_"
        model.setValue(hls_url, forKey: p + "hls_url")
        model.setValue(poster_url, forKey: p + "poster_url")
    }

}

class VideoStreamAttribute : CompoundAttribute {
}

struct VideoStreamFormatter : ValueFormatter {

    func unformat(value: [String: AnyObject]?, attribute: VideoStreamAttribute) -> AnyObject {
        return VideoStreamSpine(value)
    }

    func format(value: VideoStreamSpine, attribute: VideoStreamAttribute) -> AnyObject {
        // Implement in case we need it.
        return NSNull()
    }

}

class DualStreamSpine : CompoundValue {

    let attribute = VideoStreamAttribute()
    let formatter = VideoStreamFormatter()

    var stream_a: VideoStreamSpine?
    var stream_b: VideoStreamSpine?

    init(_ dict: [String: AnyObject]) {
        if let value = dict["stream_a"] as? [String: AnyObject] {
            self.stream_a = formatter.unformat(value, attribute: attribute) as? VideoStreamSpine
        }
        if let value = dict["stream_b"] as? [String: AnyObject] {
            self.stream_b = formatter.unformat(value, attribute: attribute) as? VideoStreamSpine
        }
    }

    override func saveToCoreData(model: BaseModel) {
        self.stream_a?.saveToCoreData(model, withPrefix: "stream_a")
        self.stream_b?.saveToCoreData(model, withPrefix: "stream_b")
    }

}

class DualStreamAttribute : CompoundAttribute {
}

struct DualStreamFormatter : ValueFormatter {

    func unformat(value: [String: AnyObject], attribute: DualStreamAttribute) -> AnyObject {
        return DualStreamSpine(value)
    }

    func format(value: DualStreamSpine, attribute: DualStreamAttribute) -> AnyObject {
        // Implement in case we need it.
        return NSNull()
    }

}
