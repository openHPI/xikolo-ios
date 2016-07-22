//
//  Error.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

enum XikoloError : ErrorType {

    case API(SpineError)
    case CoreData(NSError)
    case InvalidData
    case ModelIncomplete
    case Network(NSError)

    case UnknownError(ErrorType)
    case TotallyUnknownError

}
