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

    var quiz: Quiz!

    var loadingHelper: ViewControllerLoadingHelper!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingHelper = ViewControllerLoadingHelper(self, rootView: view)
        loadingHelper.startLoading(quiz.item?.title ?? NSLocalizedString("Loading", comment: "Loading"))

        QuizHelper.refreshQuiz(quiz).onSuccess { quiz in
            if quiz.show_welcome_page {
                self.loadingHelper.stopLoading()
                self.configureUI()
            } else {
                self.performSegueWithIdentifier("QuizReplaceSegue", sender: nil)
            }
        }
    }

    func configureUI() {
        titleView.text = quiz.item?.title
        textView.text = quiz.instructions
    }

    @IBAction func startQuiz(sender: UIButton) {
        performSegueWithIdentifier("QuizShowSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
            case "QuizShowSegue"?, "QuizReplaceSegue"?:
                let vc = segue.destinationViewController as! ItemQuizViewController
                vc.quiz = quiz
            default:
                super.prepareForSegue(segue, sender: sender)
        }
    }

}
