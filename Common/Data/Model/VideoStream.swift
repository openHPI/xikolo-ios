//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class VideoStream: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

    public var hdURL: URL?
    public var sdURL: URL?
    public var hlsURL: URL?
    public var hdSize: Int?
    public var sdSize: Int?
    public var thumbnailURL: URL?

    public required init(object: ResourceData) throws {
        self.hdURL = try object.failsafeURL(for: "hd_url")
        self.sdURL = try object.failsafeURL(for: "sd_url")
        self.hlsURL = try object.failsafeURL(for: "hls_url")
        self.hdSize = try object.value(for: "hd_size")
        self.sdSize = try object.value(for: "sd_size")
        self.thumbnailURL = try object.failsafeURL(for: "thumbnail_url")
    }

    public required init(coder decoder: NSCoder) {
        self.hdURL = decoder.decodeObject(of: NSURL.self, forKey: "hd_url")?.absoluteURL
        self.sdURL = decoder.decodeObject(of: NSURL.self, forKey: "sd_url")?.absoluteURL
        self.hlsURL = decoder.decodeObject(of: NSURL.self, forKey: "hls_url")?.absoluteURL
        self.hdSize = decoder.decodeObject(of: NSNumber.self, forKey: "hd_size")?.intValue
        self.sdSize = decoder.decodeObject(of: NSNumber.self, forKey: "sd_size")?.intValue
        self.thumbnailURL = decoder.decodeObject(of: NSURL.self, forKey: "thumbnail_url")?.absoluteURL
    }

    public func encode(with coder: NSCoder) {

        coder.encode(self.hdURL?.asNSURL(), forKey: "hd_url")
        coder.encode(self.sdURL?.asNSURL(), forKey: "sd_url")
        coder.encode(self.hlsURL?.asNSURL(), forKey: "hls_url")
        coder.encode(self.hdSize.map(NSNumber.init(value:)), forKey: "hd_size")
        coder.encode(self.sdSize.map(NSNumber.init(value:)), forKey: "sd_size")
        coder.encode(self.thumbnailURL?.asNSURL(), forKey: "thumbnail_url")
    }

}
