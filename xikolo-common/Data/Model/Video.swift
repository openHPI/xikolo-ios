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
    
    override func iconName() -> String {
        return "video"
    }

    var hlsURL: URL? {
        guard let urlString = self.single_stream_hls_url else {
            return nil
        }
        return URL(string: urlString)
    }

    func metadata() -> [AVMetadataItem] {
        var items: [AVMetadataItem] = []
        if let course_item = self.item, let item = AVMetadataItem.item(AVMetadataCommonIdentifierTitle, value: course_item.title) {
            items.append(item)
        }
        if let item = AVMetadataItem.item(AVMetadataCommonIdentifierDescription, value: summary) {
            items.append(item)
        }
        return items
    }

}

class VideoSpine : ContentSpine {

    var summary: String?
    var duration: NSNumber?

    var slides_url: URL?
    var audio_url: URL?
    var transcript_url: URL?
    var thumbnail_url: URL?

    var slides_size: NSNumber?
    var audio_size: NSNumber?
    var transcript_size: NSNumber?

    var single_stream: VideoStreamSpine?
    var lecturer_stream: VideoStreamSpine?
    var slides_stream: VideoStreamSpine?

    override class var cdType: BaseModel.Type {
        return Video.self
    }

    override class var resourceType: ResourceType {
        return "videos"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "summary": Attribute(),
            "duration": Attribute(),
            "slides_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "slides_size": Attribute(),
            "audio_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "audio_size": Attribute(),
            "transcript_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "transcript_size": Attribute(),
            "thumbnail_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "single_stream": VideoStreamAttribute(prefix: "single_stream")
// if the following attributes are processed this will lead to single stream url is overwritten due to the hardcoded single_stream prefix in saveToCoreData. As they are not used deactivate them for now.
//          "lecturer_stream": VideoStreamAttribute(prefix: "lecturer_stream"),
//          "slides_stream": VideoStreamAttribute(prefix: "slides_stream"),
        ])
    }

}

class VideoStreamSpine : CompoundValue {

    var hls_url: String?
    var thumbnail_url: String?

    init(_ dict: [String: AnyObject]?) {
        if let dict = dict {
            self.hls_url = dict["hls_url"] as? String
            self.thumbnail_url = dict["thumbnail_url"] as? String
        }
    }

    override func saveToCoreData(model: BaseModel) {
        self.saveToCoreData(model, withPrefix: "single_stream")
    }

    func saveToCoreData(_ model: BaseModel, withPrefix prefix: String) {
        let p = prefix + "_"
        model.setValue(hls_url, forKey: p + "hls_url")
        model.setValue(thumbnail_url, forKey: p + "thumbnail_url")
    }

}

class VideoStreamAttribute : CompoundAttribute {
    let prefix: String?

    public init(prefix: String? = nil) {
        self.prefix = prefix
    }
}

struct VideoStreamFormatter : ValueFormatter {
    typealias FormattedType = [String: AnyObject]
    typealias UnformattedType = VideoStreamSpine
    typealias AttributeType = VideoStreamAttribute

    func unformatValue(_ value: FormattedType, forAttribute: AttributeType) -> UnformattedType {
        return VideoStreamSpine(value)
    }

    func formatValue(_ value: UnformattedType, forAttribute: AttributeType) -> FormattedType {
        // Implement in case we need it.
        return [:]
    }

}
