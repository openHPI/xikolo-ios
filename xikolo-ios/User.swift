//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var id : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var visual : String = ""
    var token : String = ""
    
    override init() {
        super.init()
    }
    
    init(id: String, firstName: String, lastName: String, email: String, visual: String, token: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.visual = visual
        self.token = token
    }

}
