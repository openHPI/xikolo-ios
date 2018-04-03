//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

final class Channel: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String?
    @NSManaged var slug: String?
    @NSManaged var color: String?
    @NSManaged var position: Int32
    @NSManaged var channelDescription: String?
    @NSManaged var mobileImageURL: URL?

    @NSManaged var courses: Set<Course>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

}

extension Channel: Pullable {

    static var type: String {
        return "channels"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.name = try attributes.value(for: "name")
        self.slug = try attributes.value(for: "slug")
        self.color = try attributes.value(for: "color")
        self.position = try attributes.value(for: "position")
        self.channelDescription = try attributes.value(for: "description")
        self.mobileImageURL = try attributes.value(for: "mobile_image_url")

        guard let relationships = try? object.value(for: "relationships") as JSON else { return }

        try self.updateRelationship(forKeyPath: \Channel.courses,
                                    forKey: "courses",
                                    fromObject: relationships,
                                    including: includes,
                                    inContext: context)
    }

}
