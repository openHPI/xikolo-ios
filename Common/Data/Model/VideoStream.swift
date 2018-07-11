//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public final class VideoStream: NSObject, NSCoding, IncludedPullable {

    public var hdURL: URL?
    public var sdURL: URL?
    public var hlsURL: URL?
    public var hdSize: Int32?
    public var sdSize: Int32?
    public var thumbnailURL: URL?

    required public init(object: ResourceData) throws {
        self.hdURL = try object.value(for: "hd_url")
        self.sdURL = try object.value(for: "sd_url")
        self.hlsURL = try object.value(for: "hls_url")
        self.hdSize = try object.value(for: "hd_size")
        self.sdSize = try object.value(for: "sd_size")
        self.thumbnailURL = try object.value(for: "thumbnail_url")
    }

    required public init(coder decoder: NSCoder) {
        self.hdURL = decoder.decodeObject(forKey: "hd_url") as? URL
        self.sdURL = decoder.decodeObject(forKey: "sd_url") as? URL
        self.hlsURL = decoder.decodeObject(forKey: "hls_url") as? URL
        self.hdSize = decoder.decodeObject(forKey: "hd_size") as? Int32
        self.sdSize = decoder.decodeObject(forKey: "sd_size") as? Int32
        self.thumbnailURL = decoder.decodeObject(forKey: "thumbnail_url") as? URL
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.hdURL, forKey: "hd_url")
        coder.encode(self.sdURL, forKey: "sd_url")
        coder.encode(self.hlsURL, forKey: "hls_url")
        coder.encode(self.hdSize, forKey: "hd_size")
        coder.encode(self.sdSize, forKey: "sd_size")
        coder.encode(self.thumbnailURL, forKey: "thumbnail_url")
    }

}
