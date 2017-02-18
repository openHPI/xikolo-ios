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

    var options: [QuizOption]!
    var submissionLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66

        tableView.allowsMultipleSelection = question.questionType == .multipleAnswer

        if question.shuffle_answers {
            options = question.options?.shuffle() ?? []
        } else {
            options = question.options ?? []
        }

        loadSubmission()
        submissionLoaded = true
    }

    func loadSubmission() {
        guard let submissionAnswers = question.submission?.answers else {
            return
        }
        for answerSubmission in submissionAnswers {
            guard let index = options.index(where: { $0.id == answerSubmission }) else {
                continue
            }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    override func saveSubmission() {
        question.submission = nil
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let answers = indexPaths.map { self.options[$0.row] }
            if answers.count > 0 {
                let submission = QuizQuestionSubmission(question: question)
                submission.answers = answers.map { $0.id }.filter { $0 != nil }.map { $0! }
                question.submission = submission
            }
        }
    }

}

extension ChoiceQuestionViewController : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAnswerCell") as! ChoiceAnswerCell
        let answer = options[indexPath.row]

        var state: ChoiceOptionState? = nil
        if question.hasCorrectnessData, let answerID = answer.id, let correct = answer.correct, let submissionAnswers = question.submission?.answers {
            let selected = submissionAnswers.contains(answerID)
            if correct {
                state = .correct
            } else if selected {
                state = .incorrectSelected
            } else {
                state = .incorrectUnselected
            }
        }

        cell.configure(answer, choiceState: state)
        return cell
    }

}

extension ChoiceQuestionViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return !readOnly || !submissionLoaded ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return !readOnly || !submissionLoaded ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

}
