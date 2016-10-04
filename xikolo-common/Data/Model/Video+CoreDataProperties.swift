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
    @NSManaged var single_stream_hls_url: String?
    @NSManaged var single_stream_poster_url: String?
    @NSManaged var slides_url: NSURL?
    @NSManaged var stream_a_hls_url: String?
    @NSManaged var stream_a_poster_url: String?
    @NSManaged var stream_b_hls_url: String?
    @NSManaged var stream_b_poster_url: String?
    @NSManaged var summary: String?
    @NSManaged var transcript_url: NSURL?
    @NSManaged var thumbnail_url: NSURL?

}
