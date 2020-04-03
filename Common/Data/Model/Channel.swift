//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

public final class Channel: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var channelDescription: String?
    @NSManaged public var slug: String?
    @NSManaged public var colorString: String?
    @NSManaged public var position: Int16
    @NSManaged public var imageURL: URL?
    @NSManaged public var stageStream: VideoStream?

    @NSManaged public var courses: Set<Course>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

}

extension Channel: JSONAPIPullable {

    public static var type: String {
        return "channels"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.channelDescription = try attributes.value(for: "description")
        self.slug = try attributes.value(for: "slug")
        self.colorString = try attributes.value(for: "color")
        self.position = try attributes.value(for: "position")
        self.imageURL = try attributes.failsafeURL(for: "mobile_image_url")
        self.stageStream = try attributes.value(for: "stage_stream") ?? self.stageStream

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Self.courses, forKey: "courses", fromObject: relationships, with: context)
        }
    }

}
