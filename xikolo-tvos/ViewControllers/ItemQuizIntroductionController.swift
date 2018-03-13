//
//  ItemQuizIntroductionController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 23.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import SDWebImage

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
            return submission.submitted ? .submissionSubmitted : .submissionUnsubmitted
        }
        return .noSubmission
    }

    var backgroundImageHelper: ViewControllerBlurredBackgroundHelper!
    var loadingHelper: ViewControllerLoadingHelper!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let course = quiz.item?.section?.course {
            backgroundImageHelper = ViewControllerBlurredBackgroundHelper(rootView: view)
            backgroundImageHelper.imageView.sd_setImage(with: course.image_url)
        }

        loadingHelper = ViewControllerLoadingHelper(self, rootView: view)
        loadingHelper.startLoading(quiz.item?.title ?? NSLocalizedString("Loading", comment: "Loading"))

        QuizHelper.sync(quiz).onSuccess { quiz in
            if quiz.show_welcome_page {
                self.loadingHelper.stopLoading()
                self.configureUI()
            } else {
                self.performSegue(withIdentifier: "QuizReplaceSegue", sender: false)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !loadingHelper.isLoading {
            // Don't configure when the quiz is loading. It will be configured anyway.
            configureUI()
        }
    }

    func configureUI() {
        titleView.text = quiz.item?.title
        if let text = quiz.instructions {
            textView.attributedText = try? MarkdownHelper.parse(text)
        }

        let formattedTimeLimit = quiz.formattedTimeLimit
        let timeLimitHidden = formattedTimeLimit.count == 0
        timeLimitHeaderView.isHidden = timeLimitHidden
        timeLimitView.isHidden = timeLimitHidden
        if !timeLimitHidden {
            timeLimitView.text = formattedTimeLimit.joined(separator: "\n")
        }

        switch submissionState {
            case .noSubmission:
                showSubmissionButton.isHidden = true
            case .submissionUnsubmitted:
                showSubmissionButton.isHidden = true
                startQuizButton.setTitle(NSLocalizedString("Continue Quiz", comment: "Continue Quiz"), for: UIControlState())
            case .submissionSubmitted:
                showSubmissionButton.isHidden = false
                startQuizButton.setTitle(NSLocalizedString("Retake Quiz", comment: "Retake Quiz"), for: UIControlState())
                // TODO: Disable "Retake Quiz" button if the user has no more attempts.
        }
    }

    @IBAction func showSubmission(_ sender: UIButton) {
        performSegue(withIdentifier: "QuizShowSegue", sender: true)
    }

    @IBAction func startQuiz(_ sender: UIButton) {
        performSegue(withIdentifier: "QuizShowSegue", sender: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "QuizShowSegue"?, "QuizReplaceSegue"?:
                let vc = segue.destination as! ItemQuizViewController
                vc.quiz = quiz
                if (sender as! Bool) {
                    vc.submissionMode = .showSubmission
                } else {
                    vc.submissionMode = QuizSubmissionDisplayMode.fromSubmissionState(submissionState)
                }
            default:
                super.prepare(for: segue, sender: sender)
        }
    }

}

enum QuizSubmissionState {

    case noSubmission
    case submissionUnsubmitted
    case submissionSubmitted

}

enum QuizSubmissionDisplayMode {

    case takeQuiz
    case continueQuiz
    case retakeQuiz
    case showSubmission

    static func fromSubmissionState(_ state: QuizSubmissionState) -> QuizSubmissionDisplayMode {
        switch(state) {
            case .noSubmission: return .takeQuiz
            case .submissionUnsubmitted: return .continueQuiz
            case .submissionSubmitted: return .retakeQuiz
        }
    }

}
