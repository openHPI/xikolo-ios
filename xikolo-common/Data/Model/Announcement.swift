//
//  Announcement.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

final class Announcement: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var text: String?
    @NSManaged var publishedAt: Date?
    @NSManaged var visited: Bool
    @NSManaged var imageURL: URL?
    @NSManaged private var objectStateValue: Int16

    @NSManaged var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Announcement> {
        return NSFetchRequest<Announcement>(entityName: "Announcement");
    }

}


extension Announcement: Pullable {

    static var type: String {
        return "announcements"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.text = try attributes.value(for: "text")
        self.imageURL = try attributes.value(for: "image_url")
        self.publishedAt = try attributes.value(for: "published_at")
        self.visited = try attributes.value(for: "visited")

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Announcement.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
        }
    }

}

extension Announcement : Pushable {

    var objectState: ObjectState {
        get {
            return ObjectState(rawValue: self.objectStateValue)!
        }
        set {
            self.objectStateValue = newValue.rawValue
        }
    }

    func markAsUnchanged() {
        self.objectState = .unchanged
    }

    func resourceAttributes() -> [String : Any] {
        return [ "visited": self.visited ]
    }

}
