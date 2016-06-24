//
//  ServiceProvider.swift
//  TopShelf
//
//  Created by Sebastian Brückner on 24.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {

    override init() {
        super.init()
    }

    var topShelfStyle: TVTopShelfContentStyle {
        return .Sectioned
    }

    var topShelfItems: [TVContentItem] {
        return []
    }

}
