//
//  Video.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 30.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class Video : Content {
    
    override func iconName() -> String {
        return "video"
    }

}

class VideoSpine : BaseModelSpine {
    
    override class var cdType: BaseModel.Type {
        return Video.self
    }

    override class var resourceType: ResourceType {
        return "videos"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([:])
    }

}
