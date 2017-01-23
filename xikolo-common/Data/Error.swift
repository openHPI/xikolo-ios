//
//  Error.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

enum XikoloError : Error {

    case api(SpineError)
    case coreData(NSError)
    case invalidData
    case modelIncomplete
    case network(Error)
    case authenticationError
    case markdownError

    case unknownError(Error)
    case totallyUnknownError

}
