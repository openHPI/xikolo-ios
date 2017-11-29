//
//  PeerAssessment.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

final class PeerAssessment : Content {

    @NSManaged var id: String
    @NSManaged var title: String?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PeerAssessment> {
        return NSFetchRequest<PeerAssessment>(entityName: "PeerAssessment");
    }

}

extension PeerAssessment : Pullable {

    static var type: String {
        return "peer-assessments"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
    }

}

