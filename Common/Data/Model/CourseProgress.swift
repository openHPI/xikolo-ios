//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

public final class CourseProgress: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var mainProgress: ExerciseProgress
    @NSManaged public var selftestProgress: ExerciseProgress
    @NSManaged public var bonusProgress: ExerciseProgress
    @NSManaged public var visitProgress: VisitProgress
    @NSManaged public var sectionProgresses: Set<SectionProgress>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseProgress> {
        return NSFetchRequest<CourseProgress>(entityName: "CourseProgress")
    }

}

extension CourseProgress: JSONAPIPullable {

    public static var type: String {
        return "course-progresses"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.mainProgress = try attributes.value(for: "main_exercises")
        self.selftestProgress = try attributes.value(for: "selftest_exercises")
        self.bonusProgress = try attributes.value(for: "bonus_exercises")
        self.visitProgress = try attributes.value(for: "visits")

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Self.sectionProgresses,
                                        forKey: "section_progresses",
                                        fromObject: relationships,
                                        with: context)
        }
    }

}
