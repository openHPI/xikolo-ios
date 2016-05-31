//
//  Video+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Video {

    @NSManaged var audio_url: String?
    @NSManaged var duration: NSNumber?
    @NSManaged var id: String?
    @NSManaged var single_stream_hls_url: String?
    @NSManaged var single_stream_poster_url: String?
    @NSManaged var slides_url: String?
    @NSManaged var stream_a_hls_url: String?
    @NSManaged var stream_a_poster_url: String?
    @NSManaged var stream_b_hls_url: String?
    @NSManaged var stream_b_poster_url: String?
    @NSManaged var subtitles_url: String?
    @NSManaged var transcript_url: String?
    @NSManaged var video_description: String?

}
