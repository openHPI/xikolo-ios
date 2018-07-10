//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

public final class RichText: Content {

    @NSManaged public var id: String
    @NSManaged public var text: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RichText> {
        return NSFetchRequest<RichText>(entityName: "RichText")
    }

    public override var isAvailableOffline: Bool {
        return self.text != nil
    }

}

extension RichText: Pullable {

    public static var type: String {
        return "rich-texts"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.text = try attributes.value(for: "text")
    }

}
