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

    func configure(answer: QuizAnswer, choiceState: ChoiceAnswerState? = nil) {
        textView.text = answer.text

        if let state = choiceState {
            switch state {
                case .Correct:
                    backgroundColor = UIColor.greenColor()
                case .IncorrectSelected:
                    backgroundColor = UIColor.redColor()
                case .IncorrectUnselected:
                    backgroundColor = UIColor.lightGrayColor()
            }
        }
    }

}

enum ChoiceAnswerState {

    case Correct
    case IncorrectSelected
    case IncorrectUnselected

}
