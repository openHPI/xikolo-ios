//
//  ItemQuizIntroductionController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ItemQuizIntroductionController : UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var timeLimitHeaderView: UILabel!
    @IBOutlet weak var timeLimitView: UILabel!

    @IBOutlet weak var showSubmissionButton: UIButton!
    @IBOutlet weak var startQuizButton: UIButton!

    var quiz: Quiz!
    var submissionState: QuizSubmissionState {
        if let submission = quiz.submission {
            return submission.submitted ? .SubmissionSubmitted : .SubmissionUnsubmitted
        }
        return .NoSubmission
    }

    var backgroundImageHelper: ViewControllerBlurredBackgroundHelper!
    var loadingHelper: ViewControllerLoadingHelper!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let course = quiz.item?.section?.course {
            backgroundImageHelper = ViewControllerBlurredBackgroundHelper(rootView: view)
            course.loadImage().onSuccess { image in
                self.backgroundImageHelper.imageView.image = image
            }
        }

        loadingHelper = ViewControllerLoadingHelper(self, rootView: view)
        loadingHelper.startLoading(quiz.item?.title ?? NSLocalizedString("Loading", comment: "Loading"))

        QuizHelper.refreshQuiz(quiz).onSuccess { quiz in
            if quiz.show_welcome_page {
                self.loadingHelper.stopLoading()
                self.configureUI()
            } else {
                self.performSegueWithIdentifier("QuizReplaceSegue", sender: false)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !loadingHelper.isLoading {
            // Don't configure when the quiz is loading. It will be configured anyway.
            configureUI()
        }
    }

    func configureUI() {
        titleView.text = quiz.item?.title
        if let text = quiz.instructions {
            textView.attributedText = MarkdownParser.parse(text)
        }

        let formattedTimeLimit = quiz.time_limit_formatted
        let timeLimitHidden = formattedTimeLimit.count == 0
        timeLimitHeaderView.hidden = timeLimitHidden
        timeLimitView.hidden = timeLimitHidden
        if !timeLimitHidden {
            timeLimitView.text = formattedTimeLimit.joinWithSeparator("\n")
        }

        switch submissionState {
            case .NoSubmission:
                showSubmissionButton.hidden = true
            case .SubmissionUnsubmitted:
                showSubmissionButton.hidden = true
                startQuizButton.setTitle(NSLocalizedString("Continue Quiz", comment: "Continue Quiz"), forState: .Normal)
            case .SubmissionSubmitted:
                showSubmissionButton.hidden = false
                startQuizButton.setTitle(NSLocalizedString("Retake Quiz", comment: "Retake Quiz"), forState: .Normal)
                // TODO: Disable "Retake Quiz" button if the user has no more attempts.
        }
    }

    @IBAction func showSubmission(sender: UIButton) {
        performSegueWithIdentifier("QuizShowSegue", sender: true)
    }

    @IBAction func startQuiz(sender: UIButton) {
        performSegueWithIdentifier("QuizShowSegue", sender: false)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "QuizShowSegue"?, "QuizReplaceSegue"?:
                let vc = segue.destinationViewController as! ItemQuizViewController
                vc.quiz = quiz
                if (sender as! Bool) {
                    vc.submissionMode = .ShowSubmission
                } else {
                    vc.submissionMode = QuizSubmissionDisplayMode.fromSubmissionState(submissionState)
                }
            default:
                super.prepareForSegue(segue, sender: sender)
        }
    }

}

enum QuizSubmissionState {

    case NoSubmission
    case SubmissionUnsubmitted
    case SubmissionSubmitted

}

enum QuizSubmissionDisplayMode {

    case TakeQuiz
    case ContinueQuiz
    case RetakeQuiz
    case ShowSubmission

    static func fromSubmissionState(state: QuizSubmissionState) -> QuizSubmissionDisplayMode {
        switch(state) {
            case .NoSubmission: return .TakeQuiz
            case .SubmissionUnsubmitted: return .ContinueQuiz
            case .SubmissionSubmitted: return .RetakeQuiz
        }
    }

}
