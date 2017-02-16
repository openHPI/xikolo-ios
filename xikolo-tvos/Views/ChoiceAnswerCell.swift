//
//  ChoiceAnswerCell.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 18.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ChoiceAnswerCell : UITableViewCell {

    @IBOutlet weak var textView: UILabel!

    func configure(_ option: QuizOption, choiceState: ChoiceOptionState? = nil) {
        textView.text = option.text

        if let state = choiceState {
            switch state {
                case .correct:
                    backgroundColor = Brand.CorrectAnswerColor
                case .incorrectSelected:
                    backgroundColor = Brand.IncorrectAnswerColor
                case .incorrectUnselected:
                    backgroundColor = Brand.WrongAnswerColor
            }
        }
    }

}

enum ChoiceOptionState {

    case correct
    case incorrectSelected
    case incorrectUnselected

}
