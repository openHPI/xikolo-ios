//
//  AbstractQuestionViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 17.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class AbstractQuestionViewController : UIViewController {

    @IBOutlet weak var textView: UILabel!

    var question: QuizQuestion!
    var readOnly = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let text = question.text {
            textView.attributedText = try? MarkdownHelper.parse(text)
        }
    }

    func saveSubmission() {
    }

}
