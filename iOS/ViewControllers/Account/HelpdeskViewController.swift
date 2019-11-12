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
            NSLocalizedString("helpdesk.topic.reactivation", comment: "helpdesk topic reactivation"),
            NSLocalizedString("helpdesk.topic.course-specific", comment: "helpdesk topic course-specific"),
        ]

        if !Brand.default.features.enableReactivation {
            items.remove(at: 1)
        }

        let issueTypeSegmentedControl = UISegmentedControl(items: items)
        issueTypeSegmentedControl.selectedSegmentIndex = 0
        issueTypeSegmentedControl.addTarget(self, action: #selector(issueTopicChanged), for: .valueChanged)
        issueTypeSegmentedControl.addTarget(self, action: #selector(issueAttributeChanged), for: .valueChanged)
        return issueTypeSegmentedControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.delegate = self
        self.coursePicker.delegate = self as UIPickerViewDelegate
        self.coursePicker.dataSource = self as UIPickerViewDataSource
        self.issueText.delegate = self as UITextViewDelegate

        if UserProfileHelper.shared.isLoggedIn {
            self.tableView.deleteSections([1], with: .none)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
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


    @IBAction private func issueTopicChanged() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    @IBAction private func issueAttributeChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = HelpdeskTicketHelper.validate(title: issueTitleTextField.text, email: mailAddressTextField.text, report: issueText.text, typeIndex : self.issueTypeSegmentedControl.selectedSegmentIndex, courseIndex : coursePicker.selectedRow(inComponent: 0), numberOfSegments : self.issueTypeSegmentedControl.numberOfSegments)
    }

    @IBAction private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func send() {
        let selectedTopic = issueTypeSegmentedControl.titleForSegment(at: issueTypeSegmentedControl.selectedSegmentIndex)
        let topic : HelpdeskTicket.Topic
        let course : Course = self.courses[coursePicker.selectedRow(inComponent: 0) - 1]
        switch selectedTopic {
        case "technical":
            topic = .technical
        case "reactivation":
            topic = .reactivation
        case "course-specific":
            topic = .courseSpecific(course: course)
        default :
            topic = .technical
        }

        let ticket = HelpdeskTicket(title: issueTitleTextField.text ?? "", email: mailAddressTextField.text ?? "", topic: topic, report: issueText.text ?? "")

        if let resourceData = ticket.resourceData().value {
            print(String(data: resourceData, encoding: .utf8))
        }
    }
//        self.dismiss(animated: trueUnlessReduceMotionEnabled)
//        print(issueTitleTextField.text!,
//              mailAddressTextField.text!,
//              issueText.text!,
//              issueTypeSegmentedControl.titleForSegment(at: issueTypeSegmentedControl.selectedSegmentIndex)!)
//        if issueTypeSegmentedControl.selectedSegmentIndex == issueTypeSegmentedControl.numberOfSegments - 1 {
//            print(self.courses[coursePicker.selectedRow(inComponent: 0) - 1].title!)
//       }

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
            self.issueAttributeChanged()
        }

}

    extension HelpdeskViewController: UITextViewDelegate {

        func textViewDidChange(_ tableView: UITextView) {
            self.issueAttributeChanged()

            // use of performWithoutAnimation() in order to avoid rocking of the textView
            UIView.performWithoutAnimation(){
                self.issueText.sizeToFit()
                self.issueTextCell.sizeToFit()
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }


