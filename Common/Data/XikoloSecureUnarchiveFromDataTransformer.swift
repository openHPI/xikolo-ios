//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

@available(iOS 12.0, *)
@objc(XikoloSecureUnarchiveFromDataTransformer)
class XikoloSecureUnarchiveFromDataTransformer: NSSecureUnarchiveFromDataTransformer {

    static let name = NSValueTransformerName(rawValue: String(describing: XikoloSecureUnarchiveFromDataTransformer.self))

    override class var allowedTopLevelClasses: [AnyClass] {
        return [
            ExerciseProgress.self,
            CourseCertificates.self,
            CourseCertificatesHash.self,
            EnrollmentCertificates.self,
            QuizOption.self,
            TrackingEventUser.self,
            TrackingEventVerb.self,
            TrackingEventResource.self,
            VideoStream.self,
            VisitProgress.self,
            AutomatedDownloadSettings.self,
        ]
    }

    public static func register() {
        let transformer = XikoloSecureUnarchiveFromDataTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }

}
