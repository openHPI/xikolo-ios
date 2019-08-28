//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

public final class EnrollmentCertificates: NSObject, NSCoding, IncludedPullable {

    public var confirmationOfParticipation: URL?
    public var recordOfAchievement: URL?
    public var qualifiedCertificate: URL?

    public required init(object: ResourceData) throws {
        let recordOfAchievementURLString = try attributes.value(for: "recordOfAchievement_url") as String
        self.recordOfAchievement = URL(string: recordOfAchievementURLString.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let confirmationOfParticipationURLString = try attributes.value(for: "confirmationOfParticipation_url") as String
        self.confirmationOfParticipation = URL(string: confirmationOfParticipationURLString.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let qualifiedCertificateURLString = try attributes.value(for: "qualifiedCertificate_url") as String
        self.qualifiedCertificate = URL(string: qualifiedCertificateURLString.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    public required init(coder decoder: NSCoder) {
        self.confirmationOfParticipation = decoder.decodeObject(forKey: "confirmation_of_participation") as? URL
        self.recordOfAchievement = decoder.decodeObject(forKey: "record_of_achievement") as? URL
        self.qualifiedCertificate = decoder.decodeObject(forKey: "qualified_certificate") as? URL
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(self.qualifiedCertificate, forKey: "qualified_certificate")
    }

}
