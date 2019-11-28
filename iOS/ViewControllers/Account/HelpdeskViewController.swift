//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit

class HelpdeskViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {

    @IBOutlet private weak var titleTextField: UITextField!
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

        if !Brand.default.features.enableHelpdeskReactivationTopic {
            items.remove(at: 1)
        }

        let issueTypeSegmentedControl = UISegmentedControl(items: items)
        issueTypeSegmentedControl.selectedSegmentIndex = 0
        issueTypeSegmentedControl.addTarget(self, action: #selector(issueTopicChanged), for: .valueChanged)
        issueTypeSegmentedControl.addTarget(self, action: #selector(issueAttributeChanged), for: .valueChanged)
        return issueTypeSegmentedControl
    }()

    var hasValidInput: Bool {
        guard let issueTitle = self.titleTextField.text, !issueTitle.components(separatedBy: .whitespacesAndNewlines).joined().isEmpty
            else { return false }
        guard let mailAddress = self.mailAddressTextField.text, !mailAddress.components(separatedBy: .whitespacesAndNewlines).joined().isEmpty
            else { return false }
        guard let issueReport = self.reportTextView.text, !issueReport.components(separatedBy: .whitespacesAndNewlines).joined().isEmpty
            else { return false }

        let selectedCourseIndex = self.issueTypeSegmentedControl.selectedSegmentIndex
        let reactivationEnabled = Brand.default.features.enableHelpdeskReactivationTopic
        let notCourseSpecificTopic = reactivationEnabled && (selectedCourseIndex != 2) || !reactivationEnabled && selectedCourseIndex != 1
        let courseSelected = self.coursePicker.selectedRow(inComponent: 0) != 0
        return notCourseSpecificTopic || courseSelected
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tableView.delegate = self
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.reportTextView.delegate = self
        self.titleTextField.delegate = self
        self.mailAddressTextField.delegate = self

        self.onFailureLabel.isHidden = true

        if UserProfileHelper.shared.isLoggedIn {
            CoreDataHelper.viewContext.perform {
                guard let userId = UserProfileHelper.shared.userId else { return }
                    let fetchRequest = UserHelper.FetchRequest.user(withId: userId)
                guard let user = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return }
                self.mailAddressTextField.text = user.profile?.email
                self.mailAddressTextField.isUserInteractionEnabled = false
                self.mailAddressTextField.textColor = .gray
            }
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.resizeTableHeaderView()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 { return 65 } // Segmented Control for topic
        return super.tableView(tableView, heightForHeaderInSection: section)
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

    @IBAction private func issueTopicChanged() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    @IBAction private func issueAttributeChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = self.hasValidInput

        if #available(iOS 13.0, *) {
            guard let issueTitle = self.titleTextField.text, !issueTitle.isEmpty else {
                isModalInPresentation = true
                return
            }

            if !UserProfileHelper.shared.isLoggedIn {
                guard let mailAddress = self.mailAddressTextField.text, !mailAddress.isEmpty else {
                isModalInPresentation = true
                return
                }

            }

            guard let issueReport = self.reportTextView.text, !issueReport.isEmpty else {
                isModalInPresentation = true
                return
            }

            isModalInPresentation = false

        }

    }

    @IBAction private func cancel() {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction private func send() {
        guard let title = titleTextField.text else { return }
        guard let mail = mailAddressTextField.text else { return }
        guard let report = reportTextView.text else { return }
        let selectedIndex = issueTypeSegmentedControl.selectedSegmentIndex
        let topic: HelpdeskTicket.Topic
        switch selectedIndex {
        case 0:
            topic = .technical
        case 1 :
            if Brand.default.features.enableHelpdeskReactivationTopic {
                topic = .reactivation

            } else {
                let course: Course = self.courses[coursePicker.selectedRow(inComponent: 0) - 1]
                topic = .courseSpecific(course: course)
            }
        case 2:
            let course: Course = self.courses[coursePicker.selectedRow(inComponent: 0) - 1]
            topic = .courseSpecific(course: course)
        default :
            topic = .technical
        }

        let ticket = HelpdeskTicket(title: title, mail: mail, topic: topic, report: report)

        HelpdeskTicketHelper.createIssue(ticket).onSuccess { _ in
            self.dismiss(animated: trueUnlessReduceMotionEnabled)
        }.onFailure { _ in
            self.onFailureLabel.isHidden = false
            self.tableView.setContentOffset( CGPoint(x: 0, y: 0), animated: true)
        }
    }

    @IBAction private func tappedBackground() {
        self.titleTextField.resignFirstResponder()
        self.mailAddressTextField.resignFirstResponder()
        self.reportTextView.resignFirstResponder()
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
        UIView.performWithoutAnimation {
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

        if textField == self.titleTextField && !UserProfileHelper.shared.isLoggedIn {
            self.mailAddressTextField.becomeFirstResponder()
        } else if textField === self.mailAddressTextField || textField == self.titleTextField && UserProfileHelper.shared.isLoggedIn {
            self.reportTextView.becomeFirstResponder()
            // jump to textView
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
        }

        return true
    }

}
