//
//  ResourceIdentifier.swift
//  xikolo-ios
//
//  Created by Max Bothe on 27.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import Marshal

struct ResourceIdentifier: Unmarshaling {

    let type: String
    let id: String

    init(object: ResourceData) throws {
        self.type = try object.value(for: "type")
        self.id = try object.value(for: "id")
    }

}
