//
//  ChoiceQuestionViewController.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 17.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class ChoiceQuestionViewController : AbstractQuestionViewController {

    @IBOutlet weak var tableView: UITableView!

    override var readOnly: Bool {
        didSet {
            tableView?.reloadData()
        }
    }

    var answers: [QuizAnswer]!
    var submissionLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66

        tableView.allowsMultipleSelection = question.questionType == .MultipleAnswer

        if question.shuffle_answers {
            answers = question.answers?.shuffle() ?? []
        } else {
            answers = question.answers ?? []
        }

        loadSubmission()
        submissionLoaded = true
    }

    func loadSubmission() {
        guard let submissionAnswers = question.submission?.answers else {
            return
        }
        for answerSubmission in submissionAnswers {
            guard let index = answers.indexOf({ $0.id == answerSubmission }) else {
                continue
            }
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }

    override func saveSubmission() {
        question.submission = nil
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let answers = indexPaths.map { self.answers[$0.row] }
            if answers.count > 0 {
                let submission = QuizQuestionSubmission(question: question)
                submission.answers = answers.map { $0.id }.filter { $0 != nil }.map { $0! }
                question.submission = submission
            }
        }
    }

}

extension ChoiceQuestionViewController : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceAnswerCell") as! ChoiceAnswerCell
        let answer = answers[indexPath.row]

        var state: ChoiceAnswerState? = nil
        if let answerID = answer.id, correct = answer.correct, submissionAnswers = question.submission?.answers {
            let selected = submissionAnswers.contains(answerID) ?? false
            if correct {
                state = .Correct
            } else if selected {
                state = .IncorrectSelected
            } else {
                state = .IncorrectUnselected
            }
        }

        cell.configure(answer, choiceState: state)
        return cell
    }

}

extension ChoiceQuestionViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return !readOnly || !submissionLoaded ? indexPath : nil
    }

    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return !readOnly || !submissionLoaded ? indexPath : nil
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }

}
