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

    func configure(answer: QuizAnswer) {
        textView.text = answer.text
    }

}
