//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

public final class Document: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var documentDescription: String?
    @NSManaged public var isPublic: Bool
    @NSManaged private var tagArray: NSArray

    @NSManaged public var courses: Set<Course>
    @NSManaged public var localizations: Set<DocumentLocalization>

    public var tags: [String] {
        get {
            return self.tagArray as? [String] ?? []
        }
        set {
            self.tagArray = newValue as NSArray
        }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

}

extension Document: Pullable {

    public static var type: String {
        return "documents"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.documentDescription = try attributes.value(for: "description")
        self.isPublic = try attributes.value(for: "public")
        self.tags = try attributes.value(for: "tags")

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Document.localizations,
                                        forKey: "localizations",
                                        fromObject: relationships,
                                        including: includes,
                                        inContext: context)
        }
    }

}
