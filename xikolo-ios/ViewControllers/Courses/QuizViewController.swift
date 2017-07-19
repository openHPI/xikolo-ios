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
    @IBOutlet weak var pointsView: UILabel!
    @IBOutlet weak var instructionView: UITextView!
    @IBOutlet weak var timelimitView: UILabel!
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
            instructionView.attributedText = markdown
        }
        if let points = quiz.max_points {
            pointsView.text = points.description(withLocale: Locale.current) + " " + NSLocalizedString("achievable points", comment: "")
        } else {
            pointsView.isHidden = true
        }
        if var timelimit = quiz.time_limit as? Int, timelimit != 0 {
            timelimit = timelimit / 60 // given in seconds, displayed in minutes
            timelimitView.text = NSLocalizedString("max. ", comment: "") + timelimit.description + " " + NSLocalizedString("minutes", comment: "")
        } else {
            timelimitView.isHidden = true
            timelimitView.text = ""
        }
        var buttonTitle = NSLocalizedString("Start Quiz", comment: "")
        if let attempts = quiz.allowed_attempts as? Int, attempts > 0 { // TODO: user attempt handling
            buttonTitle += " (" + attempts.description
            if attempts == 1 {
                buttonTitle += NSLocalizedString(" attempt", comment: "")
            } else {
                buttonTitle += NSLocalizedString(" attempts", comment: "")
            }
            buttonTitle += ")"
        }
        startQuizButton.setTitle(buttonTitle, for: .normal)
    }

    @IBAction func startQuiz(_ sender: Any) {
        performSegue(withIdentifier: "StartQuiz", sender: quiz)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartQuiz" {
            let vc = segue.destination as! QuizQuestionViewController
            vc.quiz = quiz
        }
    }

}
