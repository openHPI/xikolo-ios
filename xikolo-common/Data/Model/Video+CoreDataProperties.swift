//
//  Video+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 21.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData

extension Video {

    @NSManaged var duration: NSNumber?
    @NSManaged var slides_url: URL?
    @NSManaged var slides_size: NSNumber?
    @NSManaged var audio_url: URL?
    @NSManaged var audio_size: NSNumber?
    @NSManaged var transcript_url: URL?
    @NSManaged var transcript_size: NSNumber?
    @NSManaged var thumbnail_url: URL?
    @NSManaged var single_stream_hls_url: String?
    @NSManaged var single_stream_thumbnail_url: String?
    @NSManaged var lecturer_stream_hls_url: String?
    @NSManaged var lecturer_stream_thumbnail_url: String?
    @NSManaged var slides_stream_hls_url: String?
    @NSManaged var slides_stream_thumbnail_url: String?
    @NSManaged var summary: String?
    @NSManaged var download_date: Date?
    @NSManaged var local_file_bookmark: NSData?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video");
    }

}
