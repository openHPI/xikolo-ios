//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

public final class DocumentLocalization: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var localizationDescription: String?
    @NSManaged public var languageCode: String?
    @NSManaged public var fileURL: URL?
    @NSManaged public var localFileBookmark: NSData?
    @NSManaged private var revision: Int16

    @NSManaged public var document: Document

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentLocalization> {
        return NSFetchRequest<DocumentLocalization>(entityName: "DocumentLocalization")
    }

}

extension DocumentLocalization: JSONAPIPullable {

    public static var type: String {
        return "document-localizations"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.localizationDescription = try attributes.value(for: "description")
        self.languageCode = try attributes.value(for: "language")
        self.fileURL = try attributes.failsafeURL(for: "file_url")
        self.revision = try attributes.value(for: "revision")
    }

}

extension DocumentLocalization {

    public var filename: String {
        return [self.document.title, self.title].compactMap { $0 }.joined(separator: " - ")
    }

}
