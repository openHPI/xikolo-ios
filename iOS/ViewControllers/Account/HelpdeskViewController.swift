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
    @IBOutlet private weak var reportTextView: UITextView!
    @IBOutlet private weak var pickerCell: UITableViewCell!
    @IBOutlet private weak var issueTextCell: UITableViewCell!
    @IBOutlet private weak var onFailureLabel: UILabel!

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

    var user : User?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.delegate = self
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.reportTextView.delegate = self
        self.issueTitleTextField.delegate = self
        self.mailAddressTextField.delegate = self

        self.onFailureLabel.isHidden = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && UserProfileHelper.shared.isLoggedIn { return 0 }
        if section == 2 { return 65 } // Segmented Control for topic
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return self.issueTypeSegmentedControl.selectedSegmentIndex == issueTypeSegmentedControl.numberOfSegments - 1 ? 216.0 : 0
        }

        if indexPath.section == 1 && UserProfileHelper.shared.isLoggedIn {
            return 0
        }
        else if indexPath.section == 1 && !UserProfileHelper.shared.isLoggedIn {
            return 44
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


    @IBAction private func issueTopicChanged() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    @IBAction private func issueAttributeChanged() {
//        let topic : HelpdeskTicket.Topic
//        let selectedIndex = self.issueTypeSegmentedControl.selectedSegmentIndex
//        var courseTitle = ""
//        var course : Course
//        switch selectedIndex {
//        case 0:
//            topic = .technical
//        case 1 :
//            if Brand.default.features.enableReactivation {
//                topic = .reactivation
//
//            }
//            else {
//                //way of avoiding forced unwrap?
//                courseTitle = self.courses[coursePicker.selectedRow(inComponent: 0) - 1].title ?? ""
//                course = (self.courses[coursePicker.selectedRow(inComponent: 0) - 1]) ?? nil
//                topic = .courseSpecific(course: course!)
//            }
//        case 2:
//            //way of avoiding forced unwrap?
//            course = self.courses[coursePicker.selectedRow(inComponent: 0) - 1] ?? ""
//            course = (self.courses[coursePicker.selectedRow(inComponent: 0) - 1]) ?? nil
//            topic = .courseSpecific(course: course!)
//        default :
//            topic = .technical
//        }
//        let ticketIsValid = HelpdeskTicketHelper.validate(title: issueTitleTextField.text,
//                                                          email: mailAddressTextField.text,
//                                                          report: reportTextView.text,
//                                                          topic: topic,
//                                                          course: course
//                                                          )
        let mail = UserProfileHelper.shared.isLoggedIn ? self.user?.profile?.email : mailAddressTextField.text
        let ticketIsValid = HelpdeskTicket.validate(title: issueTitleTextField.text,
                                                                  email: mail,
                                                                  report: reportTextView.text,
                                                                  topic: issueTypeSegmentedControl.selectedSegmentIndex,
                                                                  course: coursePicker.selectedRow(inComponent: 0)
                                                                  )
        self.navigationItem.rightBarButtonItem?.isEnabled = ticketIsValid
    }

    @IBAction private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func send() {
        guard let title = issueTitleTextField.text else { return }

        let selectedIndex = issueTypeSegmentedControl.selectedSegmentIndex
        let topic : HelpdeskTicket.Topic
        switch selectedIndex {
        case 0:
            topic = .technical
        case 1 :
            if Brand.default.features.enableReactivation {
                topic = .reactivation

            }
            else {
                let course : Course = self.courses[coursePicker.selectedRow(inComponent: 0) - 1]
                topic = .courseSpecific(course: course)
            }
        case 2:
            let course : Course = self.courses[coursePicker.selectedRow(inComponent: 0) - 1]
            topic = .courseSpecific(course: course)
        default :
            topic = .technical
        }
        let mail = UserProfileHelper.shared.isLoggedIn ? self.user?.profile?.email : mailAddressTextField.text
        let ticket = HelpdeskTicket(title: title, mail: mail ?? "", topic: topic, report: reportTextView.text ?? "")

        //scroll to top
        self.onFailureLabel.isHidden = false
        //self.onFailureLabel.sizeToFit()
        self.tableView.resizeTableHeaderView()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.tableView.setContentOffset(.zero , animated: true)

//        HelpdeskTicketHelper.createIssue(ticket).onSuccess { _ in
//            self.dismiss(animated: trueUnlessReduceMotionEnabled)
//        }.onFailure { _ in
//            //scroll to top, show error notification
//            self.tableView.scrollsToTop = true
//            print("error")
//        }
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
        self.issueAttributeChanged()
    }

}

extension HelpdeskViewController: UITextViewDelegate {

    func textViewDidChange(_ tableView: UITextView) {
        self.issueAttributeChanged()

        // use of performWithoutAnimation() in order to avoid rocking of the textView
        UIView.performWithoutAnimation(){
            self.reportTextView.sizeToFit()
            self.issueTextCell.sizeToFit()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

extension HelpdeskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let reportFieldIndex = UserProfileHelper.shared.isLoggedIn ? IndexPath(row: 0, section: 2) : IndexPath(row: 0, section:3)

        if textField == self.issueTitleTextField && !UserProfileHelper.shared.isLoggedIn {
            self.mailAddressTextField.becomeFirstResponder()
        } else if textField === self.mailAddressTextField {
            self.reportTextView.becomeFirstResponder()
            //jump to textView
            self.tableView.scrollToRow(at: reportFieldIndex, at: .top, animated: true)
        }

        return true
    }

}


