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

    @IBAction private func indexSelected(_ sender: Any) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    @IBAction private func onValueChange(_ sender: Any) {
        guard (issueText.text != nil) &&
            (!issueText.text!.isEmpty) &&
            (issueTitleTextField.text != nil) &&
            (!issueTitleTextField.text!.isEmpty) &&
            (mailAddressTextField.text != nil) &&
            (!mailAddressTextField.text!.isEmpty) else { self.navigationItem.rightBarButtonItem!.isEnabled = false
            return

        }

        if coursePicker.selectedRow(inComponent: 0) != 0 || issueTypeSegmentedControl.selectedSegmentIndex != issueTypeSegmentedControl.numberOfSegments - 1 {
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        } else { self.navigationItem.rightBarButtonItem!.isEnabled = false
            return
        }
    }

    @IBAction private func cancel(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func send(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
        print(issueTitleTextField.text!,
              mailAddressTextField.text!,
              issueText.text!,
              issueTypeSegmentedControl.titleForSegment(at: issueTypeSegmentedControl.selectedSegmentIndex)!)
        if issueTypeSegmentedControl.selectedSegmentIndex == issueTypeSegmentedControl.numberOfSegments - 1 {
            print(self.courses[coursePicker.selectedRow(inComponent: 0) - 1].title!)
        }
    }

    lazy var issueTypeSegmentedControl: UISegmentedControl = {
        let items = [
            NSLocalizedString("helpdesk.topic.technical", comment: "helpdesk topic technical"),
            NSLocalizedString("helpdesk.topic.course-specific", comment: "helpdesk topic course-specific"),
        ]
        var issueTypeSegmentedControl = UISegmentedControl(items: items)
        if Brand.default.features.enableReactivation {
            let string = NSLocalizedString("helpdesk.topic.reactivation", comment: "helpdesk topic reactivation")
            issueTypeSegmentedControl.insertSegment(withTitle: string, at: 1, animated: false)
        }

        issueTypeSegmentedControl.selectedSegmentIndex = 0
        issueTypeSegmentedControl.addTarget(self, action: #selector(indexSelected(_:)), for: .valueChanged)
        issueTypeSegmentedControl.addTarget(self, action: #selector(onValueChange(_:)), for: .valueChanged)
        return issueTypeSegmentedControl
    }()

    private lazy var courses: [Course] = {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses).value
        return result ?? []
    }()

    var course: Course?
    var user: User?

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return issueTypeSegmentedControl.selectedSegmentIndex == issueTypeSegmentedControl.numberOfSegments - 1 ? 216.0 : 0
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 2 else { return nil }
        let view = UIView()
        view.addSubview(issueTypeSegmentedControl)
        view.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 65)
        issueTypeSegmentedControl.frame = CGRect(x: 0, y: 13, width: view.bounds.width, height: 44)
        issueTypeSegmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 2 else { return super.tableView(tableView, heightForHeaderInSection: section) }
        return 65
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem!.isEnabled = false
        self.tableView.delegate = self
        coursePicker.delegate = self
        coursePicker.dataSource = self
        issueText.delegate = self

        if let user = user {
            self.tableView.deleteSections([1], with: UITableView.RowAnimation(rawValue: 0)!)
            self.tableView.beginUpdates()
                 self.tableView.endUpdates()
        }

        if let course = course {
            issueTypeSegmentedControl.removeAllSegments()
            issueTypeSegmentedControl.insertSegment(withTitle: course.title, at: 0, animated: false)
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
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
        self.onValueChange((Any).self)
    }
}

extension HelpdeskViewController: UITextViewDelegate {
    func textViewDidChange(_ tableView: UITextView) {
        self.onValueChange((Any).self)
        UIView.setAnimationsEnabled(false)
        issueText.sizeToFit()
        issueTextCell.sizeToFit()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
