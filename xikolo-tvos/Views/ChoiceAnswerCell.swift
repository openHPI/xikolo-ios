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

    func configure(option: QuizOption, choiceState: ChoiceOptionState? = nil) {
        textView.text = option.text

        if let state = choiceState {
            switch state {
                case .Correct:
                    backgroundColor = Brand.CorrectAnswerColor
                case .IncorrectSelected:
                    backgroundColor = Brand.IncorrectAnswerColor
                case .IncorrectUnselected:
                    backgroundColor = Brand.WrongAnswerColor
            }
        }
    }

}

enum ChoiceOptionState {

    case Correct
    case IncorrectSelected
    case IncorrectUnselected

}
