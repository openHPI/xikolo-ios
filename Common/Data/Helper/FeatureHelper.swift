//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Stockpile

public enum FeatureHelper {

    public enum FeatureIdentifier: String {
        case quizRecap = "quiz_recap"
        case courseReactivation = "course_reactivation"

        // Identifiers for content notification and automated downloads user test
        case newContentNotification = "mobile.new_content.notification"
        case newContentBackgroundDownload = "mobile.new_content.background_download"
    }

    @discardableResult
    public static func syncFeatures() -> Future<Void, XikoloError> {
        let query = SingleResourceQuery(type: Feature.self, id: "")
        return XikoloSyncEngine().synchronize(withFetchRequest: Self.FetchRequest.globalFeatures, withQuery: query).asVoid()
    }

    @discardableResult
    public static func syncFeatures(forCourse course: Course) -> Future<Void, XikoloError> {
        let query = SingleResourceQuery(type: CourseFeature.self, id: course.id)
        return XikoloSyncEngine().synchronize(withFetchRequest: Self.FetchRequest.features(forCourse: course), withQuery: query).asVoid()
    }

    public static func hasFeature(_ featureIdentifier: FeatureIdentifier, for course: Course? = nil) -> Bool {
        #if DEBUG
        if featureIdentifier == .newContentNotification && CommandLine.arguments.contains("-new-content-notification") {
            return true
        } else if featureIdentifier == .newContentBackgroundDownload && CommandLine.arguments.contains("-new-content-background-download") {
            return true
        }
        #endif

        let hasFeatureInGlobalScope: Bool = {
            let fetchRequest = Self.FetchRequest.globalFeatures
            guard let features = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return false }
            return features.features.contains(featureIdentifier.rawValue)
        }()

        let hasFeatureInCourseScope: Bool = {
            guard let course = course else { return false }
            let fetchRequest = Self.FetchRequest.features(forCourse: course)
            guard let courseFeatures = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return false }
            return courseFeatures.features.contains(featureIdentifier.rawValue)
        }()

        return hasFeatureInGlobalScope || hasFeatureInCourseScope
    }

}
