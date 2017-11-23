//
//  Content.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData

class Content : NSManagedObject {

    func iconName() -> String {
        // TODO: Add "unsupported" icon.
        return "homework"
    }

    var isAvailableOffline: Bool {
        return false
    }

}

extension Content : AbstractPullable {}
