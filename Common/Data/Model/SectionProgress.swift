//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine


public final class SectionProgress: NSManagedObject {

    @NSManaged public var id: String

    @NSManaged public var title: String
    @NSManaged public var mainProgress: ExerciseProgress
    @NSManaged public var selftestProgress: ExerciseProgress
    @NSManaged public var bonusProgress: ExerciseProgress
    @NSManaged public var visitProgress: VisitProgress

    @NSManaged public var items: Set<CourseItem>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionProgress> {
        return NSFetchRequest<SectionProgress>(entityName: "SectionProgress")
    }

}
