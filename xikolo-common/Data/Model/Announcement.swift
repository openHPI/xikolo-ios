//
//  Announcement.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
//import Spine

@objcMembers
final class Announcement: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var text: String?
    @NSManaged var publishedAt: Date?
    @NSManaged var visited: Bool
    @NSManaged var imageURLString: String?
    @NSManaged var course: Course?

    var imageURL: URL? {
        get {
            guard let value = self.imageURLString else { return nil }
            return URL(string: value)
        }
        set {
            self.imageURLString = newValue?.absoluteString
        }
    }

//    var visited: Bool? {
//        get {
//            return visited_int?.boolValue
//        }
//        set(new_has_visited) {
//            visited_int = new_has_visited as NSNumber?
//        }
//    }

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
        self.imageURLString = try attributes.value(for: "image_url")
        self.publishedAt = try attributes.value(for: "published_at")
        self.visited = try attributes.value(for: "visited")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \Announcement.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
    }

}



//@objcMembers
//class AnnouncementSpine : BaseModelSpine {
//
//    var title: String?
//    var text: String?
//    var published_at: Date?
//    var visited_int: NSNumber?
//    var image_url: URL?
//
//    var course: CourseSpine?
//
//    //used for PATCH
//    convenience init(announcementItem: Announcement){
//        self.init()
//        self.id = announcementItem.id
//        self.visited_int = announcementItem.visited_int
//    }
//
//    override class var cdType: BaseModel.Type {
//        return Announcement.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "announcements"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "title": Attribute().readOnly(),
//            "text": Attribute().readOnly(),
//            "published_at": DateAttribute().readOnly(),
//            "visited_int": BooleanAttribute().serializeAs("visited"),
//            "image_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
//            "course": ToOneRelationship(CourseSpine.self).readOnly(),
//        ])
//    }
//
//}

