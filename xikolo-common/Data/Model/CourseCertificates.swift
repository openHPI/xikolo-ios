//
//  CourseCertificates.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 15.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

@objcMembers
class CourseCertificates : NSObject, NSCoding, EmbeddedObject {

    var confirmationOfParticipation: CourseCertificatesHash?
    var recordOfAchievement: CourseCertificatesHash?
    var certificate: CourseCertificatesHash?

    required init(_ dict: [String : AnyObject]) {
        confirmationOfParticipation = dict["confirmation_of_participation"] as? CourseCertificatesHash
        recordOfAchievement = dict["record_of_achievement"] as? CourseCertificatesHash
        certificate = dict["qualified_certificate"] as? CourseCertificatesHash
    }

    required init(coder decoder: NSCoder) {
        confirmationOfParticipation = decoder.decodeObject(forKey: "confirmation_of_participation") as? CourseCertificatesHash
        recordOfAchievement = decoder.decodeObject(forKey: "record_of_achievement") as? CourseCertificatesHash
        certificate = decoder.decodeObject(forKey: "qualified_certificate") as? CourseCertificatesHash
    }

    func encode(with coder: NSCoder) {
        coder.encode(confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(certificate, forKey: "qualified_certificate")
    }
    
}
