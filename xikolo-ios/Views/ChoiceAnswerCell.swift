//
//  ChoiceAnswerCell.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 17.07.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

class ChoiceAnswerCell : UITableViewCell {

    @IBOutlet weak var titleView: UILabel!

    func configure(_ option: QuizOption, choiceState: ChoiceOptionState? = nil) {
        titleView.text = option.text

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
