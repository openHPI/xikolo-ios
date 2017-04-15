//
//  CourseCertificates.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 15.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation

class CourseCertificates : NSObject, NSCoding, EmbeddedObject {

    var confirmationOfParticipation: Bool?
    var recordOfAchievement: Bool?
    var certificate: Bool?

    required init(_ dict: [String : AnyObject]) {
        confirmationOfParticipation = dict["confirmationOfParticipation"] as? Bool
        recordOfAchievement = dict["recordOfAchievement"] as? Bool
        certificate = dict["certificate"] as? Bool
    }

    required init(coder decoder: NSCoder) {
        confirmationOfParticipation = decoder.decodeObject(forKey: "confirmationOfParticipation") as? Bool
        recordOfAchievement = decoder.decodeObject(forKey: "recordOfAchievement") as? Bool
        certificate = decoder.decodeObject(forKey: "certificate") as? Bool
    }

    func encode(with coder: NSCoder) {
        coder.encode(confirmationOfParticipation, forKey: "confirmationOfParticipation")
        coder.encode(recordOfAchievement, forKey: "recordOfAchievement")
        coder.encode(certificate, forKey: "certificate")
    }
    
}
