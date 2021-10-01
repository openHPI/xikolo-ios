//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public final class CourseCertificates: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

    public var confirmationOfParticipation: CourseCertificatesHash?
    public var recordOfAchievement: CourseCertificatesHash?
    public var qualifiedCertificate: CourseCertificatesHash?

    public required init(object: ResourceData) throws {
        self.confirmationOfParticipation = try object.value(for: "confirmation_of_participation")
        self.recordOfAchievement = try object.value(for: "record_of_achievement")
        self.qualifiedCertificate = try object.value(for: "qualified_certificate")
    }

    public required init(coder decoder: NSCoder) {
        self.confirmationOfParticipation = decoder.decodeObject(of: CourseCertificatesHash.self, forKey: "confirmation_of_participation")
        self.recordOfAchievement = decoder.decodeObject(of: CourseCertificatesHash.self, forKey: "record_of_achievement")
        self.qualifiedCertificate = decoder.decodeObject(of: CourseCertificatesHash.self, forKey: "qualified_certificate")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(self.qualifiedCertificate, forKey: "qualified_certificate")
    }

}
