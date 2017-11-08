//
//  RichText.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Spine


class RichText : Content {

    @NSManaged var id: String
    @NSManaged var text: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RichText> {
        return NSFetchRequest<RichText>(entityName: "RichText");
    }

    override func iconName() -> String {
        return "rich_text"
    }

    override var isAvailableOffline: Bool {
        return self.text != nil
    }

}

extension RichText : Pullable {

    static var type: String {
        return "rich-texts"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.text = try attributes.value(for: "text")
    }

}

//
//@objcMembers
//class RichTextSpine : ContentSpine {
//
//    var text: String?
//
//    override class var cdType: BaseModel.Type {
//        return RichText.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "rich-texts"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "text": Attribute(),
//        ])
//    }
//
//}

