//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

final class RichText: Content {

    @NSManaged var id: String
    @NSManaged var text: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RichText> {
        return NSFetchRequest<RichText>(entityName: "RichText")
    }

    override var isAvailableOffline: Bool {
        return self.text != nil
    }

}

extension RichText: Pullable {

    static var type: String {
        return "rich-texts"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.text = try attributes.value(for: "text")
    }

}
