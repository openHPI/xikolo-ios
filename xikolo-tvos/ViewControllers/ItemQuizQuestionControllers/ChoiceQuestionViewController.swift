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

    var answers: [QuizAnswer]!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 66

        tableView.allowsMultipleSelection = question.questionType == .MultipleChoice

        if question.shuffle_answers {
            answers = question.answers?.shuffle() ?? []
        } else {
            answers = question.answers ?? []
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
        cell.configure(answer)
        return cell
    }

}

extension ChoiceQuestionViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }

}
