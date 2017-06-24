//
//  Video+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 21.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
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

}
