//
//  QuizViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 07.07.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    var courseItem: CourseItem!
    var quiz: Quiz!

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var explanationView: UITextView!
    @IBOutlet weak var startQuizButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        QuizHelper.refreshQuiz(courseItem.content as! Quiz).onSuccess { quiz in
            self.quiz = quiz
            self.updateUI(quiz: quiz)

        }
    }

    func updateUI(quiz: Quiz) {
        titleView.text = courseItem.title
        if let instructions = quiz.instructions {
            let markdown = try? MarkdownHelper.parse(instructions)
            explanationView.attributedText = markdown
        }
        /*if quiz.allowed_attempts >= quiz {
            startQuizButton.isHidden = true
        }*/
    }

    @IBAction func startQuiz(_ sender: Any) {
    }

}
