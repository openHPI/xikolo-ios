//
//  BaseModelSpine.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

class BaseModelSpine : Resource {
    
    class var cdType: BaseModel.Type {
        fatalError("Override cdType in a subclass.")
    }

}

class CompoundAttribute : Attribute {
}

class CompoundValue : NSObject {

    func saveToCoreData(model: BaseModel) {
        fatalError("Subclasses of CompoundValue need to implement saveToCoreData(model:).")
    }

}
