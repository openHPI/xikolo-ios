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
    @IBOutlet weak var issueTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var issueText: UITextView!
    @IBOutlet weak var pickerCell: UITableViewCell!
    @IBOutlet var HelpdeskTableView: UITableView!
    @IBOutlet weak var issueTextCell: UITableViewCell!

    @IBAction func indexSelected(_ sender: Any) {
        if (issueTypeSegmentedControl.selectedSegmentIndex == 1){
            pickerCell.sizeToFit()
            pickerCell.isHidden = false
            coursePicker.isHidden = false
            //self.HelpdeskTableView.numberOfRows(inSection: 2)
        }
        else {
            coursePicker.isHidden = true
            pickerCell.isHidden = true
            //self.HelpdeskTableView.numberOfRows(inSection: 2)
        }
    }

    @IBAction func onValueChange(_ sender: Any) {
        if ((mailAddressTextField.text != nil) && (mailAddressTextField.text != "") && (issueTitleTextField.text != nil) && (issueTitleTextField.text != "") &&
            (issueText.text != nil) && (issueText.text != "")){
            self.navigationItem.rightBarButtonItem!.isEnabled = true
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
    }

    @IBAction func send(_ sender: Any) {
        self.dismiss(animated: trueUnlessReduceMotionEnabled)
        print (issueTitleTextField.text!, mailAddressTextField.text!, issueText.text!)
    }

    private lazy var courseTitles: [String] = {
        let result = CoreDataHelper.viewContext.fetchMultiple(CourseHelper.FetchRequest.visibleCourses).value
        return result?.compactMap { $0.title } ?? []
    }()
    
    var course: Course?
    var user: User?

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var num: Int
//        if ((issueTypeSegmentedControl.selectedSegmentIndex == 1) && (section == 2)) {
//            num = 2
//            }
//        else {
//            num = 1
//            }
//        return num
//    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var height: CGFloat = 43.5
//        if ((indexPath.section == 2) && (indexPath.row == 1)){
//        height = 216.0
//        }
//        return height
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

    self.navigationItem.rightBarButtonItem!.isEnabled = false
        HelpdeskTableView.delegate = self
        coursePicker.delegate = self
        issueText.delegate = self

        coursePicker.isHidden = true
        pickerCell.isHidden = true
        pickerCell.sizeToFit()

        if (Brand.default.features.enableReactivation) {
            issueTypeSegmentedControl.insertSegment(withTitle: "reactivation", at: 2, animated: false)
        }

        if (user != nil) {
            HelpdeskTableView.deleteSections([1], with: UITableView.RowAnimation(rawValue: 0)!)
        }

        if let course = course {
            issueTypeSegmentedControl.removeAllSegments()
            issueTypeSegmentedControl.insertSegment(withTitle: course.title, at: 0, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           self.tableView.resizeTableHeaderView()
       }
}

extension HelpdeskViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int){
        let issueCourse = row
        print ("issueCourse =", issueCourse)
    }

    func pickerView(_ coursePicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return self.courseTitles[row]
     }

    func pickerView(_ coursePicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courseTitles.count
        //+2 to start without a chosen type
    }

    func numberOfComponents(in coursePicker: UIPickerView) -> Int {
        return 1
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

