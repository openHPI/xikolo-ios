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
        if let posterUrl = single_stream_poster_url, let url = URL(string: posterUrl) {
            return ImageProvider.loadImage(url).onSuccess { image in
                self.poster = image
            }.asVoid()
        }
        return Future.init(value: ())
    }

    func metadata() -> [AVMetadataItem] {
        var items: [AVMetadataItem] = []
        if let course_item = self.item, let item = AVMetadataItem.item(AVMetadataCommonIdentifierTitle, value: course_item.title) {
            items.append(item)
        }
        if let item = AVMetadataItem.item(AVMetadataCommonIdentifierDescription, value: summary) {
            items.append(item)
        }
        if let poster = poster, let item = AVMetadataItem.artworkItem(poster) {
            items.append(item)
        }
        return items
    }

}

class VideoSpine : ContentSpine {

    var summary: String?
    var duration: NSNumber?

    var transcript_url: URL?
    var thumbnail_url: URL?
    var slides_url: URL?

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
            "summary": Attribute(),
            "duration": Attribute(),
            "transcript_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "thumbnail_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "slides_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
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

    func saveToCoreData(_ model: BaseModel, withPrefix prefix: String) {
        let p = prefix + "_"
        model.setValue(hls_url, forKey: p + "hls_url")
        model.setValue(poster_url, forKey: p + "poster_url")
    }

}

class VideoStreamAttribute : CompoundAttribute {
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

class DualStreamSpine : CompoundValue {

    let attribute = VideoStreamAttribute()
    let formatter = VideoStreamFormatter()

    var stream_a: VideoStreamSpine?
    var stream_b: VideoStreamSpine?

    init(_ dict: [String: AnyObject]) {
        if let value = dict["stream_a"] as? [String: AnyObject] {
            self.stream_a = formatter.unformatValue(value, forAttribute: attribute)
        }
        if let value = dict["stream_b"] as? [String: AnyObject] {
            self.stream_b = formatter.unformatValue(value, forAttribute: attribute)
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
    typealias FormattedType = [String: AnyObject]
    typealias UnformattedType = DualStreamSpine
    typealias AttributeType = DualStreamAttribute

    func unformatValue(_ value: FormattedType, forAttribute: AttributeType) -> UnformattedType {
        return DualStreamSpine(value)
    }

    func formatValue(_ value: UnformattedType, forAttribute: AttributeType) -> FormattedType {
        // Implement in case we need it.
        return [:]
    }

}
