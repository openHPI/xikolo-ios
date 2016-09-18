//
//  ItemQuizViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
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
    var currentSaveOperation: Future<QuizSubmission, XikoloError>?

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
                    let submission = quiz.submission!, questions = self.questions
                    let saveOperation = { () -> Future<QuizSubmission, XikoloError> in
                        let errorMessage = NSLocalizedString("Your progress could not be saved online. Please try again later.", comment: "Your progress could not be saved online. Please try again later.")
                        return QuizHelper.saveSubmission(submission, questions: questions).onFailure(callback: self.handleError(errorMessage))
                    }
                    if currentSaveOperation == nil {
                        currentSaveOperation = saveOperation()
                    } else {
                        // Make sure the save operations happen serially.
                        currentSaveOperation = currentSaveOperation.flatMap { _ in saveOperation() }
                    }
                }
            }

            vc.removeChildViewControllerFromParent()
            questionViewController = nil
        }

        let question = questions[currentQuestion]

        let vc = viewControllerForQuestion(question)
        vc.readOnly = submissionMode! == .ShowSubmission

        addChildViewController(vc, into: questionView)

        if vc is UnsupportedQuestionViewController {
            questionFocusGuide.preferredFocusedView = previousButton
            customPreferredFocusedView = nextButton
        } else {
            questionFocusGuide.preferredFocusedView = vc.preferredFocusedView
            customPreferredFocusedView = vc.preferredFocusedView
        }

        questionViewController = vc
    }

    private func viewControllerForQuestion(question: QuizQuestion) -> AbstractQuestionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: AbstractQuestionViewController!
        switch question.questionType {
            case .SingleAnswer, .MultipleAnswer:
                vc = storyboard.instantiateViewControllerWithIdentifier("ChoiceQuestionViewController") as! ChoiceQuestionViewController
            default:
                vc = storyboard.instantiateViewControllerWithIdentifier("UnsupportedQuestionViewController") as! UnsupportedQuestionViewController
        }
        vc.question = question
        return vc
    }

    @IBAction func previousQuestion(sender: UIButton) {
        currentQuestion -= 1
    }

    @IBAction func nextQuestion(sender: UIButton) {
        if currentQuestion == questions.count - 1 {
            // Save current question.
            questionViewController?.saveSubmission()

            // TODO: Check if all questions have been answered, warn the user otherwise.

            quiz.submission!.submitted = true
            let errorMessage = NSLocalizedString("The quiz could not be submitted. Please try again later.", comment: "The quiz could not be submitted. Please try again later.")
            QuizHelper.saveSubmission(quiz.submission!, questions: questions).onFailure(callback: handleError(errorMessage))
            // TODO: Success handling.
        } else {
            currentQuestion += 1
        }
    }

    func updateButtons() {
        if currentQuestion == 0 {
            previousButton.hidden = true
        } else {
            previousButton.hidden = false
        }
        if currentQuestion == questions.count - 1 {
            nextButton.setTitle(NSLocalizedString("Finish", comment: "Finish"), forState: .Normal)
        } else {
            nextButton.setTitle(NSLocalizedString("Next", comment: "Next"), forState: .Normal)
        }
        setNeedsFocusUpdate()
    }

}

extension ItemQuizViewController : QuestionIndicatorListViewDelegate {

    func indicatorListView(indicatorListView: QuestionIndicatorListView, didSelectQuestionWithIndex index: Int) {
        currentQuestion = index
    }

}
