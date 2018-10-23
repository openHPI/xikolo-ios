//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

public final class CourseCertificates: NSObject, NSCoding, IncludedPullable {

    public var confirmationOfParticipation: CourseCertificatesHash?
    public var recordOfAchievement: CourseCertificatesHash?
    public var qualifiedCertificate: CourseCertificatesHash?

    public required init(object: ResourceData) throws {
        self.confirmationOfParticipation = try object.value(for: "confirmation_of_participation")
        self.recordOfAchievement = try object.value(for: "record_of_achievement")
        self.qualifiedCertificate = try object.value(for: "qualified_certificate")
    }

    public required init(coder decoder: NSCoder) {
        self.confirmationOfParticipation = decoder.decodeObject(forKey: "confirmation_of_participation") as? CourseCertificatesHash
        self.recordOfAchievement = decoder.decodeObject(forKey: "record_of_achievement") as? CourseCertificatesHash
        self.qualifiedCertificate = decoder.decodeObject(forKey: "qualified_certificate") as? CourseCertificatesHash
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(self.qualifiedCertificate, forKey: "qualified_certificate")
    }

}
