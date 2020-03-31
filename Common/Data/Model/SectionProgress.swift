//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

public final class SectionProgress: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var position: Int16
    @NSManaged public var available: Bool
    @NSManaged public var mainProgress: ExerciseProgress
    @NSManaged public var selftestProgress: ExerciseProgress
    @NSManaged public var bonusProgress: ExerciseProgress
    @NSManaged public var visitProgress: VisitProgress

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionProgress> {
        return NSFetchRequest<SectionProgress>(entityName: "SectionProgress")
    }

}

extension SectionProgress: JSONAPIPullable {

    public static var type: String {
        return "section-progresses"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.position = try attributes.value(for: "position")
        self.available = try attributes.value(for: "available")
        self.mainProgress = try attributes.value(for: "main_exercises")
        self.selftestProgress = try attributes.value(for: "selftest_exercises")
        self.bonusProgress = try attributes.value(for: "bonus_exercises")
        self.visitProgress = try attributes.value(for: "visits")
    }

}
