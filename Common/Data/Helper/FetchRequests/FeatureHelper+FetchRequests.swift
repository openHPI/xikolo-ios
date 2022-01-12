//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension FeatureHelper {

    public enum FetchRequest {

        static var globalFeatures: NSFetchRequest<Feature> {
            let request: NSFetchRequest<Feature> = Feature.fetchRequest()
            request.fetchLimit = 1
            return request
        }

        static func features(forCourse course: Course) -> NSFetchRequest<CourseFeature> {
            let request: NSFetchRequest<CourseFeature> = CourseFeature.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", course.id)
            request.fetchLimit = 1
            return request
        }

    }

}
