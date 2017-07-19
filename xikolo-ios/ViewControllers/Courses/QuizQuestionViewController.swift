//
//  QuizQuestionViewController.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.07.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

class QuizQuestionViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var explanationView: UITextView!
    @IBOutlet weak var containerView: UIView!

    var containerContentViewController: UIViewController?

    var quiz: Quiz!
    var questions: [QuizQuestion]!
    var currentIndex = 0

    @IBOutlet weak var previousQuestion: UIButton!
    @IBOutlet weak var nextQuestion: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let questionsSet = quiz.questions {
            self.questions = Array(questionsSet)
        }
    }

    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> QuizOptionSelectTableViewController? {
        // Return the data view controller for the given index.
        if (self.questions.count == 0) || (index >= self.questions.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let questionViewController = storyboard.instantiateViewController(withIdentifier: "QuizOptionSelectTableViewController") as! QuizOptionSelectTableViewController
        questionViewController.question = questions[index]
        questionViewController.questionIndex = index
        return questionViewController
    }

    @IBAction func previousQuestion(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            updateQuestion(questions[currentIndex]);
        }
        previousQuestion.isEnabled = currentIndex >= 0
    }

    @IBAction func nextQuestion(_ sender: Any) {
        if currentIndex < questions.count {
            currentIndex += 1
            updateQuestion(questions[currentIndex]);
        }
        nextQuestion.isEnabled = currentIndex < questions.count
    }

    func indexOfViewController(_ viewController: QuizOptionSelectTableViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return viewController.questionIndex ?? NSNotFound
    }

    func updateQuestion(_ question: QuizQuestion) {
        // TODO: Animation?
        if let vc = containerContentViewController {
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
            containerContentViewController = nil
        }

        let storyboard = UIStoryboard(name: "TabCourses", bundle: nil)
        switch question.type {
        case "select_one"?, "select_multiple"?:
            let vc = storyboard.instantiateViewController(withIdentifier: "QuizOptionSelectTableViewController") as! QuizOptionSelectTableViewController
            vc.question = question
            changeToViewController(vc)
            titleView.text = question.text
            explanationView.text = question.explanation
            vc.questionIndex = currentIndex
            explanationView.isHidden = true
        case "free_text"?:
            // TODO: implement
            break
        default:
            break
        }
        navigationController?.view.setNeedsLayout()
    }

    func changeToViewController(_ viewController: UIViewController) {
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        containerContentViewController = viewController
    }

}

extension QuizQuestionViewController : UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! QuizOptionSelectTableViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }

        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! QuizOptionSelectTableViewController)
        if index == NSNotFound {
            return nil
        }

        index += 1
        if index == self.quiz.questions?.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}
