//
//  VideoStream.swift
//  xikolo-ios
//
//  Created by Max Bothe on 08.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

final class VideoStream: NSObject, NSCoding, IncludedPullable {

    var hdURL: URL?
    var sdURL: URL?
    var hlsURL: URL?
    var hdSize: Int32?
    var sdSize: Int32?
    var thumbnailURL: URL?

    required init(object: ResourceData) throws {
        self.hdURL = try object.value(for: "hd_url")
        self.sdURL = try object.value(for: "sd_url")
        self.hlsURL = try object.value(for: "hls_url")
        self.hdSize = try object.value(for: "hd_size")
        self.sdSize = try object.value(for: "sd_size")
        self.thumbnailURL = try object.value(for: "thumbnail_url")
    }

    required init(coder decoder: NSCoder) {
        self.hdURL = decoder.decodeObject(forKey: "hd_url") as? URL
        self.sdURL = decoder.decodeObject(forKey: "sd_url") as? URL
        self.hlsURL = decoder.decodeObject(forKey: "hls_url") as? URL
        self.hdSize = decoder.decodeObject(forKey: "hd_size") as? Int32
        self.sdSize = decoder.decodeObject(forKey: "sd_size") as? Int32
        self.thumbnailURL = decoder.decodeObject(forKey: "thumbnail_url") as? URL
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.hdURL, forKey: "hd_url")
        coder.encode(self.sdURL, forKey: "sd_url")
        coder.encode(self.hlsURL, forKey: "hls_size")
        coder.encode(self.hdSize, forKey: "hd_size")
        coder.encode(self.sdSize, forKey: "sd_size")
        coder.encode(self.thumbnailURL, forKey: "thumbnail_url")
    }

}
