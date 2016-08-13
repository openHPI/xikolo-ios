//
//  ItemQuizViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ItemQuizViewController : UIViewController {

    @IBOutlet weak var indicatorView: QuestionIndicatorListView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var questionView: UIView!

    var questionFocusGuide: UIFocusGuide = UIFocusGuide()

    var quiz: Quiz!
    var questions: [QuizQuestion]!

    var currentQuestion = 0 {
        didSet {
            updateCurrentQuestion()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let quizQuestions = quiz.questions {
            // TODO: Correctly sort questions
            questions = Array(quizQuestions)

            indicatorView.questions = questions
            updateCurrentQuestion()

            view.addLayoutGuide(questionFocusGuide)
            questionFocusGuide.trailingAnchor.constraintEqualToAnchor(nextButton.leadingAnchor).active = true
            questionFocusGuide.centerYAnchor.constraintEqualToAnchor(nextButton.centerYAnchor).active = true
            questionFocusGuide.widthAnchor.constraintEqualToConstant(100).active = true
            questionFocusGuide.heightAnchor.constraintEqualToAnchor(nextButton.heightAnchor).active = true

            let previousFocusGuide = UIFocusGuide()
            view.addLayoutGuide(previousFocusGuide)
            previousFocusGuide.trailingAnchor.constraintEqualToAnchor(questionView.leadingAnchor).active = true
            previousFocusGuide.centerYAnchor.constraintEqualToAnchor(questionView.centerYAnchor).active = true
            previousFocusGuide.widthAnchor.constraintEqualToConstant(100).active = true
            previousFocusGuide.heightAnchor.constraintEqualToAnchor(questionView.heightAnchor).active = true
            previousFocusGuide.preferredFocusedView = previousButton

            let nextFocusGuide = UIFocusGuide()
            view.addLayoutGuide(nextFocusGuide)
            nextFocusGuide.leadingAnchor.constraintEqualToAnchor(questionView.trailingAnchor).active = true
            nextFocusGuide.centerYAnchor.constraintEqualToAnchor(questionView.centerYAnchor).active = true
            nextFocusGuide.widthAnchor.constraintEqualToConstant(100).active = true
            nextFocusGuide.heightAnchor.constraintEqualToAnchor(questionView.heightAnchor).active = true
            nextFocusGuide.preferredFocusedView = nextButton
        }
    }

    func updateCurrentQuestion() {
        indicatorView.activeQuestion = questions[currentQuestion]
        updateButtons()
    }

    @IBAction func previousQuestion(sender: UIButton) {
        currentQuestion -= 1
    }

    @IBAction func nextQuestion(sender: UIButton) {
        currentQuestion += 1
    }

    func updateButtons() {
        if currentQuestion == 0 {
            previousButton.hidden = true
        } else {
            previousButton.hidden = false
        }
        if currentQuestion == questions.count - 1 {
            nextButton.hidden = true
        } else {
            nextButton.hidden = false
        }
    }

}
