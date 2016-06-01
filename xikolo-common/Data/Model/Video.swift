//
//  Video.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 30.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class Video : Content {
    
    override func iconName() -> String {
        return "video"
    }

}

class VideoSpine : BaseModelSpine {

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
            "audio_url": Attribute().serializeAs("audio-url"),
            "subtitles_url": Attribute().serializeAs("subtitles-url"),
            "transcript_url": Attribute().serializeAs("transcript-url"),
            "slides_url": Attribute().serializeAs("slides-url"),
            "single_stream": VideoStreamAttribute().serializeAs("single-stream"),
            "dual_stream": DualStreamAttribute().serializeAs("dual-stream"),
        ])
    }

}

class VideoStreamSpine : CompoundValue {

    var hls_url: String?
    var poster_url: String?

    init(_ dict: [String: AnyObject]?) {
        if let dict = dict {
            self.hls_url = dict["hls-url"] as? String
            self.poster_url = dict["poster-image-url"] as? String
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
        if let value = dict["stream-a"] as? [String: AnyObject] {
            self.stream_a = formatter.unformat(value, attribute: attribute) as? VideoStreamSpine
        }
        if let value = dict["stream-b"] as? [String: AnyObject] {
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
