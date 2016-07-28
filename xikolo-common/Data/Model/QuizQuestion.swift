//
//  QuizQuestion.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 28.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

class QuizQuestion : BaseModel {

    var shuffle_answers: Bool {
        get {
            return shuffle_answers_int?.boolValue ?? false
        }
        set(new_shuffle_answers) {
            shuffle_answers_int = new_shuffle_answers
        }
    }

}
