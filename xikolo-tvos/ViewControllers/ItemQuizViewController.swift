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
            if submissionMode! == .takeQuiz || submissionMode! == .retakeQuiz {
                loadingHelper.startLoading(NSLocalizedString("Starting Quiz", comment: "Starting Quiz"))
                if submissionMode! == .retakeQuiz {
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
            questionFocusGuide.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor).isActive = true
            questionFocusGuide.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor).isActive = true
            questionFocusGuide.widthAnchor.constraint(equalToConstant: 100).isActive = true
            questionFocusGuide.heightAnchor.constraint(equalTo: nextButton.heightAnchor).isActive = true

            let previousFocusGuide = UIFocusGuide()
            view.addLayoutGuide(previousFocusGuide)
            previousFocusGuide.trailingAnchor.constraint(equalTo: questionView.leadingAnchor).isActive = true
            previousFocusGuide.centerYAnchor.constraint(equalTo: questionView.centerYAnchor).isActive = true
            previousFocusGuide.widthAnchor.constraint(equalToConstant: 100).isActive = true
            previousFocusGuide.heightAnchor.constraint(equalTo: questionView.heightAnchor).isActive = true
            previousFocusGuide.preferredFocusedView = previousButton

            let nextFocusGuide = UIFocusGuide()
            view.addLayoutGuide(nextFocusGuide)
            nextFocusGuide.leadingAnchor.constraint(equalTo: questionView.trailingAnchor).isActive = true
            nextFocusGuide.centerYAnchor.constraint(equalTo: questionView.centerYAnchor).isActive = true
            nextFocusGuide.widthAnchor.constraint(equalToConstant: 100).isActive = true
            nextFocusGuide.heightAnchor.constraint(equalTo: questionView.heightAnchor).isActive = true
            nextFocusGuide.preferredFocusedView = nextButton
        }
    }

    func updateCurrentQuestion() {
        updateQuestionView()
        updateButtons()
        setNeedsFocusUpdate()
        indicatorView.activeQuestion = questions[currentQuestion]
    }

    func updateQuestionView() {
        // TODO: Animation?
        if let vc = questionViewController {
            if !vc.question.hasCorrectnessData && !vc.readOnly {
                saveProgress(vc)
            }

            vc.removeChildViewControllerFromParent()
            questionViewController = nil
        }

        let question = questions[currentQuestion]

        let vc = viewControllerForQuestion(question)
        vc.readOnly = submissionMode! == .showSubmission || (question.hasCorrectnessData && question.submission != nil)

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

    fileprivate func saveProgress(_ vc: AbstractQuestionViewController) {
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

    fileprivate func viewControllerForQuestion(_ question: QuizQuestion) -> AbstractQuestionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: AbstractQuestionViewController!
        switch question.questionType {
            case .singleAnswer, .multipleAnswer:
                vc = storyboard.instantiateViewController(withIdentifier: "ChoiceQuestionViewController") as! ChoiceQuestionViewController
            default:
                vc = storyboard.instantiateViewController(withIdentifier: "UnsupportedQuestionViewController") as! UnsupportedQuestionViewController
        }
        vc.question = question
        return vc
    }

    @IBAction func previousQuestion(_ sender: UIButton) {
        currentQuestion -= 1
    }

    @IBAction func nextQuestion(_ sender: UIButton) {
        let vc = questionViewController!
        if vc.question.hasCorrectnessData && !vc.readOnly {
            saveProgress(vc)
            if vc.question.submission != nil {
                vc.readOnly = true
            }
            updateButtons()
        } else {
            if currentQuestion == questions.count - 1 {
                // TODO: Check if all questions have been answered, warn the user otherwise.

                quiz.submission!.submitted = true
                let errorMessage = NSLocalizedString("The quiz could not be submitted. Please try again later.", comment: "The quiz could not be submitted. Please try again later.")
                QuizHelper.saveSubmission(quiz.submission!, questions: questions)
                    .onFailure(callback: handleError(errorMessage))
                    .onFailure { _ in
                        self.quiz.submission!.submitted = false
                    }
                // TODO: Success handling.
            } else {
                currentQuestion += 1
            }
        }
    }

    func updateButtons() {
        if currentQuestion == 0 {
            previousButton.isHidden = true
        } else {
            previousButton.isHidden = false
        }
        if questions[currentQuestion].hasCorrectnessData && !questionViewController!.readOnly {
            nextButton.setTitle(NSLocalizedString("Submit", comment: "Submit"), for: UIControlState())
        } else if currentQuestion == questions.count - 1 {
            nextButton.setTitle(NSLocalizedString("Finish", comment: "Finish"), for: UIControlState())
        } else {
            nextButton.setTitle(NSLocalizedString("Next", comment: "Next"), for: UIControlState())
        }
    }

}

extension ItemQuizViewController : QuestionIndicatorListViewDelegate {

    func indicatorListView(_ indicatorListView: QuestionIndicatorListView, didSelectQuestionWithIndex index: Int) {
        currentQuestion = index
    }

}
