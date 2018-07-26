//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

public final class DocumentLocalization: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var localizationDescription: String?
    @NSManaged private var languageCode: String?
    @NSManaged public var fileURL: URL?
    @NSManaged private var localFileURL: URL?
    @NSManaged private var revision: Int16

    @NSManaged public var document: Document

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentLocalization> {
        return NSFetchRequest<DocumentLocalization>(entityName: "DocumentLocalization")
    }

}

extension DocumentLocalization: Pullable {

    public static var type: String {
        return "document-localizations"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.localizationDescription = try attributes.value(for: "description")
        self.languageCode = try attributes.value(for: "language")
        self.fileURL = try attributes.value(for: "file_url")
        self.revision = try attributes.value(for: "revision")
    }

}
