//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

class HelpdeskViewController: UITableViewController {

    @IBOutlet private weak var issueTitleTextField: UITextField!
    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var coursePicker: UIPickerView!
    @IBOutlet private weak var issueText: UITextView!
    @IBOutlet private weak var pickerCell: UITableViewCell!
    @IBOutlet private weak var issueTextCell: UITableViewCell!

    private lazy var courses: [Course] = {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses)
        return result.value ?? []
    }()

    private lazy var issueTypeSegmentedControl: UISegmentedControl = {
        var items = [
            NSLocalizedString("helpdesk.topic.technical", comment: "helpdesk topic technical"),
            NSLocalizedString("helpdesk.topic.course-specific", comment: "helpdesk topic course-specific"),
        ]

        if Brand.default.features.enableReactivation {
            // TODO
            let string = NSLocalizedString("helpdesk.topic.reactivation", comment: "helpdesk topic reactivation")
            items.insert(string, at: 1)
        }

        let issueTypeSegmentedControl = UISegmentedControl(items: items)
        issueTypeSegmentedControl.selectedSegmentIndex = 0
        issueTypeSegmentedControl.addTarget(self, action: #selector(indexSelected), for: .valueChanged)
        issueTypeSegmentedControl.addTarget(self, action: #selector(onValueChange), for: .valueChanged)
        return issueTypeSegmentedControl
    }()

//    var course: Course?
//    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.delegate = self
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.issueText.delegate = self

        if UserProfileHelper.shared.isLoggedIn {
            self.tableView.deleteSections([1], with: .none)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

//        if let course = course {
//            issueTypeSegmentedControl.removeAllSegments()
//            issueTypeSegmentedControl.insertSegment(withTitle: course.title, at: 0, animated: false)
//        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return self.issueTypeSegmentedControl.selectedSegmentIndex == issueTypeSegmentedControl.numberOfSegments - 1 ? 216.0 : 0
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 2 else { return nil }

        let header = UIView()
        header.addSubview(self.issueTypeSegmentedControl)
        header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 65)
        self.issueTypeSegmentedControl.frame = CGRect(x: 0, y: 13, width: view.bounds.width, height: 44)
        self.issueTypeSegmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 { return 65 } // Segmented Controls for topic
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    // TODO
    @IBAction private func indexSelected() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    // TODO
    @IBAction private func onValueChange() {
        // TODO
        guard (issueText.text != nil) &&
            (!issueText.text!.isEmpty) &&
            (issueTitleTextField.text != nil) &&
            (!issueTitleTextField.text!.isEmpty) &&
            (mailAddressTextField.text != nil) &&
            (!mailAddressTextField.text!.isEmpty) else {
                self.navigationItem.rightBarButtonItem!.isEnabled = false
                return
        }

        let notCourseSpecificTopic = self.issueTypeSegmentedControl.selectedSegmentIndex != self.issueTypeSegmentedControl.numberOfSegments - 1
        let courseSelected = self.coursePicker.selectedRow(inComponent: 0) != 0
        self.navigationItem.rightBarButtonItem?.isEnabled = notCourseSpecificTopic || courseSelected
    }

    @IBAction private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func send() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
        print(issueTitleTextField.text!,
              mailAddressTextField.text!,
              issueText.text!,
              issueTypeSegmentedControl.titleForSegment(at: issueTypeSegmentedControl.selectedSegmentIndex)!)
        if issueTypeSegmentedControl.selectedSegmentIndex == issueTypeSegmentedControl.numberOfSegments - 1 {
            print(self.courses[coursePicker.selectedRow(inComponent: 0) - 1].title!)
        }
    }

}

extension HelpdeskViewController: UIPickerViewDataSource {

    func pickerView(_ coursePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        } else {
            return self.courses[row - 1].title
        }
    }

    func pickerView(_ coursePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count + 1
    }

    func numberOfComponents(in coursePicker: UIPickerView) -> Int {
        return 1
    }

}

extension HelpdeskViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        self.onValueChange()
    }

}

extension HelpdeskViewController: UITextViewDelegate {

    func textViewDidChange(_ tableView: UITextView) {
        self.onValueChange()

        // TODO
        UIView.setAnimationsEnabled(false)
        self.issueText.sizeToFit()
        self.issueTextCell.sizeToFit()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

}
