//
//  EnrollmentCertificates.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 19.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class EnrollmentCertificates : NSObject, NSCoding, EmbeddedObject {

    var confirmationOfParticipation: Bool?
    var recordOfAchievement: Bool?
    var certificate: Bool?

    required init(_ dict: [String : AnyObject]) {
        confirmationOfParticipation = dict["confirmation_of_participation"] as? Bool
        recordOfAchievement = dict["record_of_achievement"] as? Bool
        certificate = dict["qualified_certificate"] as? Bool
    }

    required init(coder decoder: NSCoder) {
        confirmationOfParticipation = decoder.decodeObject(forKey: "confirmation_of_participation") as? Bool
        recordOfAchievement = decoder.decodeObject(forKey: "record_of_achievement") as? Bool
        certificate = decoder.decodeObject(forKey: "qualified_certificate") as? Bool
    }

    func encode(with coder: NSCoder) {
        coder.encode(confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(certificate, forKey: "qualified_certificate")
    }
    
}
