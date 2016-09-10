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
    var submissionMode: QuizSubmissionDisplayMode!

    var currentQuestion = 0 {
        didSet {
            if oldValue != currentQuestion {
                updateCurrentQuestion()
            }
        }
    }
    var questionViewController: AbstractQuestionViewController?

    weak var customPreferredFocusedView: UIView!
    override weak var preferredFocusedView: UIView? {
        return customPreferredFocusedView
    }

    var backgroundImageHelper: ViewControllerBlurredBackgroundHelper!
    var loadingHelper: ViewControllerLoadingHelper!

    override func viewDidLoad() {
        super.viewDidLoad()

        indicatorView.delegate = self

        if let course = quiz.item?.section?.course {
            backgroundImageHelper = ViewControllerBlurredBackgroundHelper(rootView: view)
            course.loadImage().onSuccess { image in
                self.backgroundImageHelper.imageView.image = image
            }
        }

        if let quizQuestions = quiz.questions {
            // TODO: Correctly sort questions
            questions = Array(quizQuestions)

            loadingHelper = ViewControllerLoadingHelper(self, rootView: view)
            if submissionMode! == .TakeQuiz || submissionMode! == .RetakeQuiz {
                loadingHelper.startLoading(NSLocalizedString("Starting Quiz", comment: "Starting Quiz"))
                if submissionMode! == .RetakeQuiz {
                    // Remove all QuestionSubmissions if retaking the quiz.
                    for question in questions {
                        question.submission = nil
                    }
                }

                let submission = QuizSubmission()
                submission.submitted = false
                submission.quiz = QuizSpine(id: quiz.id)
                quiz.submission = submission

                QuizHelper.saveSubmission(submission).onSuccess { _ in
                    self.loadingHelper.stopLoading()
                }
                // TODO: Error handling
            }

            indicatorView.questions = questions
            updateCurrentQuestion()
            indicatorView.updateAll()

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
        updateButtons()
        updateQuestionView()
        indicatorView.activeQuestion = questions[currentQuestion]
    }

    func updateQuestionView() {
        // TODO: Animation?
        if let vc = questionViewController {
            if submissionMode! != .ShowSubmission {
                vc.saveSubmission()
                if vc.question.submission != nil {
                    var answers = [String: QuizQuestionSubmission]()
                    for question in questions {
                        if let submission = question.submission {
                            answers[question.id] = submission
                        }
                    }
                    quiz.submission!.answers = answers
                    QuizHelper.saveSubmission(quiz.submission!)
                }
            }

            // Hide ViewController
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            questionViewController = nil
        }

        let question = questions[currentQuestion]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: AbstractQuestionViewController!
        switch question.questionType {
            case .SingleAnswer, .MultipleAnswer:
                vc = storyboard.instantiateViewControllerWithIdentifier("ChoiceQuestionViewController") as! ChoiceQuestionViewController
            default:
                vc = storyboard.instantiateViewControllerWithIdentifier("UnsupportedQuestionViewController") as! UnsupportedQuestionViewController
        }
        vc.question = question
        vc.readOnly = submissionMode! == .ShowSubmission

        questionView.addSubview(vc.view)
        vc.view.frame = questionView.bounds
        addChildViewController(vc)
        vc.didMoveToParentViewController(self)

        if vc is UnsupportedQuestionViewController {
            questionFocusGuide.preferredFocusedView = previousButton
            customPreferredFocusedView = nextButton
        } else {
            questionFocusGuide.preferredFocusedView = vc.preferredFocusedView
            customPreferredFocusedView = vc.preferredFocusedView
        }

        questionViewController = vc
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
        setNeedsFocusUpdate()
    }

}

extension ItemQuizViewController : QuestionIndicatorListViewDelegate {

    func indicatorListView(indicatorListView: QuestionIndicatorListView, didSelectQuestionWithIndex index: Int) {
        currentQuestion = index
    }

}
