//
//  EnrollmentCertificates.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 19.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

final class EnrollmentCertificates : NSObject, NSCoding, IncludedPullable {

    var confirmationOfParticipation: Bool
    var recordOfAchievement: Bool
    var certificate: Bool

    required init(object: ResourceData) throws {
        self.confirmationOfParticipation = try object.value(for: "confirmation_of_participation")
        self.recordOfAchievement = try object.value(for: "record_of_achievement")
        self.certificate = try object.value(for: "qualified_certificate")
    }

    required init(coder decoder: NSCoder) {
        self.confirmationOfParticipation = decoder.decodeBool(forKey: "confirmation_of_participation")
        self.recordOfAchievement = decoder.decodeBool(forKey: "record_of_achievement")
        self.certificate = decoder.decodeBool(forKey: "qualified_certificate")
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(self.certificate, forKey: "qualified_certificate")
    }
    
}
