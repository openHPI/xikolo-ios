//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit
import Common
import CoreData

class HelpdeskViewController: UITableViewController {

    @IBOutlet weak var issueTitleTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var issueText: UITextView!
    @IBOutlet weak var pickerCell: UITableViewCell!
    @IBOutlet var HelpdeskTableView: UITableView!
    @IBOutlet weak var issueTextCell: UITableViewCell!
    lazy var issueTypeSegmentedControl : UISegmentedControl = {
        let items = ["technical", "course-specific"]
        var issueTypeSegmentedControl = UISegmentedControl.init(items: items)
        if (Brand.default.features.enableReactivation) {
            issueTypeSegmentedControl.insertSegment(withTitle: "reactivation", at: 2, animated: false)
        }
        issueTypeSegmentedControl.selectedSegmentIndex = 0
        issueTypeSegmentedControl.addTarget(self, action: #selector(indexSelected(_:)), for: .valueChanged)
        issueTypeSegmentedControl.addTarget(self, action: #selector(onValueChange(_:)), for: .valueChanged)
        return issueTypeSegmentedControl
    }()

    @IBAction func indexSelected(_ sender: Any) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }


    @IBAction func onValueChange(_ sender: Any) {
        guard (issueText.text != nil) && (issueText.text != "") && (issueTitleTextField.text != nil) && (issueTitleTextField.text != "") && (mailAddressTextField.text != nil) && (mailAddressTextField.text != "") else { self.navigationItem.rightBarButtonItem!.isEnabled = false
            return
        }
        if  (issueTypeSegmentedControl.selectedSegmentIndex == 1 &&
            coursePicker.selectedRow(inComponent: 0) != 0) || issueTypeSegmentedControl.selectedSegmentIndex != 1{
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        }
        else { self.navigationItem.rightBarButtonItem!.isEnabled = false
            return
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction func send(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
        print (issueTitleTextField.text!, mailAddressTextField.text!, issueText.text!,
               issueTypeSegmentedControl.titleForSegment(at: issueTypeSegmentedControl.selectedSegmentIndex)!)
        if issueTypeSegmentedControl.selectedSegmentIndex == 1 {
            print (self.titles()[coursePicker.selectedRow(inComponent: 0)])
        }
    }

    private lazy var courses: [Course] = {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses).value
        return result ?? []
    }()

    private lazy var titles = { () -> [String] in
        var result = [""]
        result += (self.courses.compactMap { $0.title })
        return result
    }
    
    var course: Course?
    var user: User?

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return issueTypeSegmentedControl.selectedSegmentIndex == 1 ? 216.0 : 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 2 else { return nil }
        let view = UIView()
        view.addSubview(issueTypeSegmentedControl)
        view.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 48)
        issueTypeSegmentedControl.frame = CGRect(x: 0, y: 13, width: view.bounds.width, height: 31)
        issueTypeSegmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 2 else { return super.tableView(tableView, heightForHeaderInSection: section) }
        return 48
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem!.isEnabled = false
        HelpdeskTableView.delegate = self
        coursePicker.delegate = self
        coursePicker.dataSource = self
        issueText.delegate = self

        if let user = user {
            HelpdeskTableView.deleteSections([1], with: UITableView.RowAnimation(rawValue: 0)!)
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
        return self.titles()[row]
    }

    func pickerView(_ coursePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.titles().count
    }

    func numberOfComponents(in coursePicker: UIPickerView) -> Int {
        return 1
    }
}

extension HelpdeskViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int){
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

