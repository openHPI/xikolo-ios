//
//  CourseCertificates.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 15.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import Marshal

final class CourseCertificates : NSObject, NSCoding, Unmarshaling {
//class CourseCertificates : NSObject, NSCoding, EmbeddedObject {

    var confirmationOfParticipation: CourseCertificatesHash?
    var recordOfAchievement: CourseCertificatesHash?
    var certificate: CourseCertificatesHash?

//    required init(_ dict: [String : AnyObject]) {
//        confirmationOfParticipation = dict["confirmation_of_participation"] as? CourseCertificatesHash
//        recordOfAchievement = dict["record_of_achievement"] as? CourseCertificatesHash
//        certificate = dict["qualified_certificate"] as? CourseCertificatesHash
//    }

    required init(object: ResourceData) throws {
        self.confirmationOfParticipation = try object.value(for: "confirmation_of_participation")
        self.recordOfAchievement = try object.value(for: "record_of_achievement")
        self.certificate = try object.value(for: "qualified_certificate")
    }

    required init(coder decoder: NSCoder) {
        self.confirmationOfParticipation = decoder.decodeObject(forKey: "confirmation_of_participation") as? CourseCertificatesHash
        self.recordOfAchievement = decoder.decodeObject(forKey: "record_of_achievement") as? CourseCertificatesHash
        self.certificate = decoder.decodeObject(forKey: "qualified_certificate") as? CourseCertificatesHash
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.confirmationOfParticipation, forKey: "confirmation_of_participation")
        coder.encode(self.recordOfAchievement, forKey: "record_of_achievement")
        coder.encode(self.certificate, forKey: "qualified_certificate")
    }
    
}

//extension CourseCertificates: Unmarshaling {
//
//    required init(object: MarshaledObject) throws {
//        self.confirmationOfParticipation = try object.value(for: "confirmation_of_participation")
//        self.recordOfAchievement = try object.value(for: "record_of_achievement")
//        self.certificate = try object.value(for: "qualified_certificate")
//    }
//
//}

